/*
 ***********************************************************************************************************************
 *
 *  Copyright (c) 2020 Advanced Micro Devices, Inc. All Rights Reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 **********************************************************************************************************************/
/**
 ***********************************************************************************************************************
 * @file  Compiler.cpp
 * @brief LLPC source file: PipelineState methods that do IR linking and compilation
 ***********************************************************************************************************************
 */
#include "lgc/LgcContext.h"
#include "lgc/PassManager.h"
#include "lgc/patch/Patch.h"
#include "lgc/state/PipelineState.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/Linker/Linker.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Timer.h"
#include "llvm/Target/TargetMachine.h"

#define DEBUG_TYPE "lgc-compiler"

using namespace lgc;
using namespace llvm;

namespace lgc {
// Create BuilderReplayer pass
ModulePass *createBuilderReplayer(Pipeline *pipeline);
} // namespace lgc

// =====================================================================================================================
// Link shader modules into a pipeline module.
//
// @param modules : Array of modules indexed by shader stage, with nullptr entry for any stage not present in the
// pipeline. Modules are freed.
Module *PipelineState::link(ArrayRef<Module *> modules) {
  // Processing for each shader module before linking.
  IRBuilder<> builder(getContext());
  Module *anyModule = nullptr;
  for (unsigned stage = 0; stage < modules.size(); ++stage) {
    Module *module = modules[stage];
    if (!module)
      continue;
    anyModule = module;

    // If this is a link of shader modules from earlier separate shader compiles, then the modes are
    // recorded in IR metadata. Read the modes here.
    getShaderModes()->readModesFromShader(module, static_cast<ShaderStage>(stage));

    // Add IR metadata for the shader stage to each function in the shader, and rename the entrypoint to
    // ensure there is no clash on linking.
    setShaderStage(module, static_cast<ShaderStage>(stage));
    for (Function &func : *module) {
      if (!func.isDeclaration() && func.getLinkage() != GlobalValue::InternalLinkage) {
        func.setName(Twine(lgcName::EntryPointPrefix) + getShaderStageAbbreviation(static_cast<ShaderStage>(stage)) +
                     "." + func.getName());
      }
    }
  }

  // If the front-end was using a BuilderRecorder, record pipeline state into IR metadata.
  if (!m_noReplayer)
    record(anyModule);

  // If there is only one shader, just change the name on its module and return it.
  Module *pipelineModule = nullptr;
  for (auto module : modules) {
    if (!pipelineModule)
      pipelineModule = module;
    else if (module) {
      pipelineModule = nullptr;
      break;
    }
  }

  if (pipelineModule)
    pipelineModule->setModuleIdentifier("llpcPipeline");
  else {
    // Create an empty module then link each shader module into it. We record pipeline state into IR
    // metadata before the link, to avoid problems with a Constant for an immutable descriptor value
    // disappearing when modules are deleted.
    bool result = true;
    pipelineModule = new Module("llpcPipeline", getContext());
    TargetMachine *targetMachine = getLgcContext()->getTargetMachine();
    pipelineModule->setTargetTriple(targetMachine->getTargetTriple().getTriple());
    pipelineModule->setDataLayout(targetMachine->createDataLayout());

    Linker linker(*pipelineModule);

    for (unsigned shaderIndex = 0; shaderIndex < modules.size(); ++shaderIndex) {
      if (modules[shaderIndex]) {
        // NOTE: We use unique_ptr here. The shader module will be destroyed after it is
        // linked into pipeline module.
        if (linker.linkInModule(std::unique_ptr<Module>(modules[shaderIndex])))
          result = false;
      }
    }

    if (!result) {
      delete pipelineModule;
      pipelineModule = nullptr;
    }
  }
  return pipelineModule;
}

// =====================================================================================================================
// Generate pipeline module by running patch, middle-end optimization and backend codegen passes.
// The output is normally ELF, but IR disassembly if an option is used to stop compilation early.
// Output is written to outStream.
// Like other Builder methods, on error, this calls report_fatal_error, which you can catch by setting
// a diagnostic handler with LLVMContext::setDiagnosticHandler.
//
// @param pipelineModule : IR pipeline module
// @param [in/out] outStream : Stream to write ELF or IR disassembly output
// @param checkShaderCacheFunc : Function to check shader cache in graphics pipeline
// @param timers : Optional timers for 0 or more of:
//                 timers[0]: patch passes
//                 timers[1]: LLVM optimizations
//                 timers[2]: codegen
void PipelineState::generate(std::unique_ptr<Module> pipelineModule, raw_pwrite_stream &outStream,
                             Pipeline::CheckShaderCacheFunc checkShaderCacheFunc, ArrayRef<Timer *> timers) {
  unsigned passIndex = 1000;
  Timer *patchTimer = timers.size() >= 1 ? timers[0] : nullptr;
  Timer *optTimer = timers.size() >= 2 ? timers[1] : nullptr;
  Timer *codeGenTimer = timers.size() >= 3 ? timers[2] : nullptr;

  // Set up "whole pipeline" passes, where we have a single module representing the whole pipeline.
  //
  // TODO: The "whole pipeline" passes are supposed to include code generation passes. However, there is a CTS issue.
  // In the case "dEQP-VK.spirv_assembly.instruction.graphics.16bit_storage.struct_mixed_types.uniform_geom", GS gets
  // unrolled to such a size that backend compilation takes too long. Thus, we put code generation in its own pass
  // manager.
  std::unique_ptr<PassManager> patchPassMgr(PassManager::Create());
  patchPassMgr->setPassIndex(&passIndex);
  patchPassMgr->add(createTargetTransformInfoWrapperPass(getLgcContext()->getTargetMachine()->getTargetIRAnalysis()));

  // Manually add a target-aware TLI pass, so optimizations do not think that we have library functions.
  getLgcContext()->preparePassManager(&*patchPassMgr);

  // Manually add a PipelineStateWrapper pass.
  // If we were not using BuilderRecorder, give our PipelineState to it. (In the BuilderRecorder case,
  // the first time PipelineStateWrapper is used, it allocates its own PipelineState and populates
  // it by reading IR metadata.)
  PipelineStateWrapper *pipelineStateWrapper = new PipelineStateWrapper(getLgcContext());
  patchPassMgr->add(pipelineStateWrapper);
  if (m_noReplayer)
    pipelineStateWrapper->setPipelineState(this);

  if (m_emitLgc) {
    // -emit-lgc: Just write the module.
    patchPassMgr->add(createPrintModulePass(outStream));
    patchPassMgr->stop();
  }

  // Get a BuilderReplayer pass if needed.
  ModulePass *replayerPass = nullptr;
  if (!m_noReplayer)
    replayerPass = createBuilderReplayer(this);

  // Patching.
  Patch::addPasses(this, *patchPassMgr, replayerPass, patchTimer, optTimer, checkShaderCacheFunc);

  // Add pass to clear pipeline state from IR
  patchPassMgr->add(createPipelineStateClearer());

  // Run the "whole pipeline" passes, excluding the target backend. Stop here if the pass manager was stopped
  // by -emit-lgc
  patchPassMgr->run(*pipelineModule);
  if (m_emitLgc)
    return;
  patchPassMgr.reset(nullptr);

  // A separate "whole pipeline" pass manager for code generation.
  std::unique_ptr<PassManager> codeGenPassMgr(PassManager::Create());
  codeGenPassMgr->setPassIndex(&passIndex);

  // Code generation.
  getLgcContext()->addTargetPasses(*codeGenPassMgr, codeGenTimer, outStream);

  // Run the target backend codegen passes.
  codeGenPassMgr->run(*pipelineModule);
}
