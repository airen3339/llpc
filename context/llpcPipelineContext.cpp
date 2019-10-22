/*
 ***********************************************************************************************************************
 *
 *  Copyright (c) 2017-2019 Advanced Micro Devices, Inc. All Rights Reserved.
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
 * @file  llpcPipelineContext.cpp
 * @brief LLPC source file: contains implementation of class Llpc::PipelineContext.
 ***********************************************************************************************************************
 */
#define DEBUG_TYPE "llpc-pipeline-context"

#include "llvm/IR/Module.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/Support/CommandLine.h"

#include "SPIRVInternal.h"
#include "llpcBuilder.h"
#include "llpcCompiler.h"
#include "llpcPipelineContext.h"
#include "llpcPipeline.h"

namespace llvm
{

namespace cl
{

extern opt<bool> EnablePipelineDump;

} // cl

} // llvm

using namespace llvm;

// -include-llvm-ir: include LLVM IR as a separate section in the ELF binary
static cl::opt<bool> IncludeLlvmIr("include-llvm-ir",
                                   cl::desc("Include LLVM IR as a separate section in the ELF binary"),
                                   cl::init(false));

// -vgpr-limit: maximum VGPR limit for this shader
static cl::opt<uint32_t> VgprLimit("vgpr-limit", cl::desc("Maximum VGPR limit for this shader"), cl::init(0));

// -sgpr-limit: maximum SGPR limit for this shader
static cl::opt<uint32_t> SgprLimit("sgpr-limit", cl::desc("Maximum SGPR limit for this shader"), cl::init(0));

// -waves-per-eu: the maximum number of waves per EU for this shader
static cl::opt<uint32_t> WavesPerEu("waves-per-eu",
                                    cl::desc("Maximum number of waves per EU for this shader"),
                                    cl::init(0));

// -enable-load-scalarizer: Enable the optimization for load scalarizer.
static cl::opt<bool> EnableScalarLoad("enable-load-scalarizer",
                                      cl::desc("Enable the optimization for load scalarizer."),
                                      cl::init(false));

// The max threshold of load scalarizer.
static const uint32_t MaxScalarThreshold = 0xFFFFFFFF;

// -scalar-threshold: Set the vector size threshold for load scalarizer.
static cl::opt<unsigned> ScalarThreshold("scalar-threshold",
                                         cl::desc("The threshold for load scalarizer"),
                                         cl::init(MaxScalarThreshold));

// -enable-si-scheduler: enable target option si-scheduler
static cl::opt<bool> EnableSiScheduler("enable-si-scheduler",
                                       cl::desc("Enable target option si-scheduler"),
                                       cl::init(false));

#if LLPC_BUILD_GFX10
// -subgroup-size: sub-group size exposed via Vulkan API.
static cl::opt<int> SubgroupSize("subgroup-size", cl::desc("Sub-group size exposed via Vulkan API"), cl::init(64));
#endif

namespace Llpc
{

// =====================================================================================================================
PipelineContext::PipelineContext(
    GfxIpVersion           gfxIp,           // Graphics IP version info
    MetroHash::Hash*       pPipelineHash,   // [in] Pipeline hash code
    MetroHash::Hash*       pCacheHash)      // [in] Cache hash code
    :
    m_gfxIp(gfxIp),
    m_pipelineHash(*pPipelineHash),
    m_cacheHash(*pCacheHash)
{

}

// =====================================================================================================================
PipelineContext::~PipelineContext()
{
}

// =====================================================================================================================
// Gets the name string of GPU target according to graphics IP version info.
void PipelineContext::GetGpuNameString(
    GfxIpVersion  gfxIp,    // Graphics IP version info
    std::string&  gpuName)  // [out] LLVM GPU name
{
    // A GfxIpVersion from PAL is three decimal numbers for major, minor and stepping. This function
    // converts that to an LLVM target name, whith is "gfx" followed by the three decimal numbers with
    // no separators, e.g. "gfx1010" for 10.1.0. A high stepping number 0xFFFA..0xFFFF denotes an
    // experimental target, and that is represented by the final hexadecimal digit, e.g. "gfx101A"
    // for 10.1.0xFFFA.
    gpuName.clear();
    raw_string_ostream gpuNameStream(gpuName);
    gpuNameStream << "gfx" << gfxIp.major << gfxIp.minor;
    if (gfxIp.stepping >= 0xFFFA)
    {
        gpuNameStream << char(gfxIp.stepping - 0xFFFA + 'A');
    }
    else
    {
        gpuNameStream << gfxIp.stepping;
    }
}

// =====================================================================================================================
// Gets the name string of the abbreviation for GPU target according to graphics IP version info.
const char* PipelineContext::GetGpuNameAbbreviation(
    GfxIpVersion gfxIp)  // Graphics IP version info
{
    const char* pNameAbbr = nullptr;
    switch (gfxIp.major)
    {
    case 6:
        pNameAbbr = "SI";
        break;
    case 7:
        pNameAbbr = "CI";
        break;
    case 8:
        pNameAbbr = "VI";
        break;
    case 9:
        pNameAbbr = "GFX9";
        break;
    default:
        pNameAbbr = "UNKNOWN";
        break;
    }

    return pNameAbbr;
}

// =====================================================================================================================
// Initializes resource usage of the specified shader stage.
void PipelineContext::InitShaderResourceUsage(
    ShaderStage    shaderStage,      // Shader stage
    ResourceUsage* pResUsage)        // [out] Resource usage
{
    memset(&pResUsage->builtInUsage, 0, sizeof(pResUsage->builtInUsage));

    pResUsage->pushConstSizeInBytes = 0;
    pResUsage->resourceWrite = false;
    pResUsage->resourceRead = false;
    pResUsage->perShaderTable = false;

    pResUsage->numSgprsAvailable = UINT32_MAX;
    pResUsage->numVgprsAvailable = UINT32_MAX;

    pResUsage->inOutUsage.inputMapLocCount = 0;
    pResUsage->inOutUsage.outputMapLocCount = 0;
    memset(pResUsage->inOutUsage.gs.outLocCount, 0, sizeof(pResUsage->inOutUsage.gs.outLocCount));
    pResUsage->inOutUsage.perPatchInputMapLocCount = 0;
    pResUsage->inOutUsage.perPatchOutputMapLocCount = 0;

    pResUsage->inOutUsage.expCount = 0;

    memset(pResUsage->inOutUsage.xfbStrides, 0, sizeof(pResUsage->inOutUsage.xfbStrides));
    pResUsage->inOutUsage.enableXfb = false;

    memset(pResUsage->inOutUsage.streamXfbBuffers, 0, sizeof(pResUsage->inOutUsage.streamXfbBuffers));

    if (shaderStage == ShaderStageVertex)
    {
        // NOTE: For vertex shader, PAL expects base vertex and base instance in user data,
        // even if they are not used in shader.
        pResUsage->builtInUsage.vs.baseVertex = true;
        pResUsage->builtInUsage.vs.baseInstance = true;
    }
    else if (shaderStage == ShaderStageTessControl)
    {
        auto& calcFactor = pResUsage->inOutUsage.tcs.calcFactor;

        calcFactor.inVertexStride           = InvalidValue;
        calcFactor.outVertexStride          = InvalidValue;
        calcFactor.patchCountPerThreadGroup = InvalidValue;
        calcFactor.offChip.outPatchStart    = InvalidValue;
        calcFactor.offChip.patchConstStart  = InvalidValue;
        calcFactor.onChip.outPatchStart     = InvalidValue;
        calcFactor.onChip.patchConstStart   = InvalidValue;
        calcFactor.outPatchSize             = InvalidValue;
        calcFactor.patchConstSize           = InvalidValue;
    }
    else if (shaderStage == ShaderStageGeometry)
    {
        pResUsage->inOutUsage.gs.rasterStream        = 0;

        auto& calcFactor = pResUsage->inOutUsage.gs.calcFactor;
        memset(&calcFactor, 0, sizeof(calcFactor));
    }
    else if (shaderStage == ShaderStageFragment)
    {
        for (uint32_t i = 0; i < MaxColorTargets; ++i)
        {
            pResUsage->inOutUsage.fs.expFmts[i] = EXP_FORMAT_ZERO;
            pResUsage->inOutUsage.fs.outputTypes[i] = BasicType::Unknown;
        }

        pResUsage->inOutUsage.fs.cbShaderMask = 0;
        pResUsage->inOutUsage.fs.dummyExport = true;
    }
}

// =====================================================================================================================
// Initializes interface data of the specified shader stage.
void PipelineContext::InitShaderInterfaceData(
    InterfaceData* pIntfData)  // [out] Interface data
{
    pIntfData->userDataCount = 0;
    memset(pIntfData->userDataMap, InterfaceData::UserDataUnmapped, sizeof(pIntfData->userDataMap));

    memset(&pIntfData->pushConst, 0, sizeof(pIntfData->pushConst));
    pIntfData->pushConst.resNodeIdx = InvalidValue;

    memset(&pIntfData->spillTable, 0, sizeof(pIntfData->spillTable));
    pIntfData->spillTable.offsetInDwords = InvalidValue;

    memset(&pIntfData->userDataUsage, 0, sizeof(pIntfData->userDataUsage));

    memset(&pIntfData->entryArgIdxs, 0, sizeof(pIntfData->entryArgIdxs));
    pIntfData->entryArgIdxs.spillTable = InvalidValue;
}

// =====================================================================================================================
// Gets the hash code of input shader with specified shader stage.
ShaderHash PipelineContext::GetShaderHashCode(
    ShaderStage stage       // Shader stage
) const
{
    auto pShaderInfo = GetPipelineShaderInfo(stage);
    LLPC_ASSERT(pShaderInfo != nullptr);

#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 36
    if((pShaderInfo->options.clientHash.upper != 0) &&
       (pShaderInfo->options.clientHash.lower != 0))
    {
        return pShaderInfo->options.clientHash;
    }
    else
    {
        ShaderHash hash = {};
        const ShaderModuleData* pModuleData = reinterpret_cast<const ShaderModuleData*>(pShaderInfo->pModuleData);

        if(pModuleData != nullptr)
        {
            hash.lower = MetroHash::Compact64(reinterpret_cast<const MetroHash::Hash*>(&pModuleData->hash));
            hash.upper = 0;
        }
        return hash;
    }
#else
    const ShaderModuleData* pModuleData = reinterpret_cast<const ShaderModuleData*>(pShaderInfo->pModuleData);

    return (pModuleData == nullptr) ? 0 :
        MetroHash::Compact64(reinterpret_cast<const MetroHash::Hash*>(&pModuleData->hash));
#endif
}

// =====================================================================================================================
// Set pipeline state in Pipeline object for middle-end
void PipelineContext::SetPipelineState(
    Pipeline*    pPipeline) const   // [in/out] Middle-end pipeline object
{
    // Give the shader stage mask to the middle-end.
    uint32_t stageMask = GetShaderStageMask();
    pPipeline->SetShaderStageMask(stageMask);

    // Give the pipeline options to the middle-end.
    SetOptionsInPipeline(pPipeline);

    // Give the user data nodes to the middle-end.
    SetUserDataInPipeline(pPipeline);

    if (IsGraphics())
    {
        // Set vertex input descriptions to the middle-end.
        SetVertexInputDescriptions(pPipeline);

        // Give the graphics pipeline state to the middle-end.
        SetGraphicsStateInPipeline(pPipeline);
    }
    else
    {
        pPipeline->SetDeviceIndex(static_cast<const ComputePipelineBuildInfo*>(GetPipelineBuildInfo())->deviceIndex);
    }
}

// =====================================================================================================================
// Give the pipeline options to the middle-end.
void PipelineContext::SetOptionsInPipeline(
    Pipeline*    pPipeline) const   // [in/out] Middle-end pipeline object
{
    Options options = {};
    options.hash[0] = GetPiplineHashCode();
    options.hash[1] = GetCacheHashCode();

    options.includeDisassembly = (cl::EnablePipelineDump || EnableOuts() || GetPipelineOptions()->includeDisassembly);
#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 28
    options.reconfigWorkgroupLayout = GetPipelineOptions()->reconfigWorkgroupLayout;
#endif
    options.includeIr = (IncludeLlvmIr || GetPipelineOptions()->includeIr);

#if LLPC_BUILD_GFX10
    if (IsGraphics() && (GetGfxIpVersion().major >= 10))
    {
        // Only set NGG options for a GFX10+ graphics pipeline.
        auto pPipelineInfo = reinterpret_cast<const GraphicsPipelineBuildInfo*>(GetPipelineBuildInfo());
        const auto& nggState = pPipelineInfo->nggState;
        if (nggState.enableNgg == false)
        {
            options.nggFlags |= NggFlagDisable;
        }
        else
        {
            options.nggFlags =
                  (nggState.enableGsUse ? NggFlagEnableGsUse : 0) |
                  (nggState.forceNonPassthrough ? NggFlagForceNonPassthrough : 0) |
                  (nggState.alwaysUsePrimShaderTable ? 0 : NggFlagDontAlwaysUsePrimShaderTable) |
                  (nggState.compactMode == NggCompactSubgroup ? NggFlagCompactSubgroup : 0) |
                  (nggState.enableFastLaunch ? NggFlagEnableFastLaunch : 0) |
                  (nggState.enableVertexReuse ? NggFlagEnableVertexReuse : 0) |
                  (nggState.enableBackfaceCulling ? NggFlagEnableBackfaceCulling : 0) |
                  (nggState.enableFrustumCulling ? NggFlagEnableFrustumCulling : 0) |
                  (nggState.enableBoxFilterCulling ? NggFlagEnableBoxFilterCulling : 0) |
                  (nggState.enableSphereCulling ? NggFlagEnableSphereCulling : 0) |
                  (nggState.enableSmallPrimFilter ? NggFlagEnableSmallPrimFilter : 0) |
                  (nggState.enableCullDistanceCulling ? NggFlagEnableCullDistanceCulling : 0);
            options.nggBackfaceExponent = nggState.backfaceExponent;
            options.nggSubgroupSizing = nggState.subgroupSizing;
            options.nggVertsPerSubgroup = nggState.vertsPerSubgroup;
            options.nggPrimsPerSubgroup = nggState.primsPerSubgroup;
        }
    }
#endif

    pPipeline->SetOptions(options);

    // Give the shader options (including the hash) to the middle-end.
    uint32_t stageMask = GetShaderStageMask();
    for (uint32_t stage = 0; stage <= ShaderStageCompute; ++stage)
    {
        if (stageMask & ShaderStageToMask(static_cast<ShaderStage>(stage)))
        {
            ShaderOptions shaderOptions = {};

            ShaderHash hash = GetShaderHashCode(static_cast<ShaderStage>(stage));
#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 36
            // 128-bit hash
            shaderOptions.hash[0] = hash.lower;
            shaderOptions.hash[1] = hash.upper;
#else
            // 64-bit hash
            shaderOptions.hash[0] = hash;
#endif

            const PipelineShaderInfo* pShaderInfo = GetPipelineShaderInfo(static_cast<ShaderStage>(stage));
            shaderOptions.trapPresent = pShaderInfo->options.trapPresent;
            shaderOptions.debugMode = pShaderInfo->options.debugMode;
            shaderOptions.allowReZ = pShaderInfo->options.allowReZ;

            if ((pShaderInfo->options.vgprLimit != 0) && (pShaderInfo->options.vgprLimit != UINT_MAX))
            {
                shaderOptions.vgprLimit = pShaderInfo->options.vgprLimit;
            }
            else
            {
                shaderOptions.vgprLimit = VgprLimit;
            }

            if ((pShaderInfo->options.sgprLimit != 0) && (pShaderInfo->options.sgprLimit != UINT_MAX))
            {
                shaderOptions.sgprLimit = pShaderInfo->options.sgprLimit;
            }
            else
            {
                shaderOptions.sgprLimit = SgprLimit;
            }

            if (pShaderInfo->options.maxThreadGroupsPerComputeUnit != 0)
            {
                shaderOptions.maxThreadGroupsPerComputeUnit = pShaderInfo->options.maxThreadGroupsPerComputeUnit;
            }
            else
            {
                shaderOptions.maxThreadGroupsPerComputeUnit = WavesPerEu;
            }

#if LLPC_BUILD_GFX10
            shaderOptions.waveSize = pShaderInfo->options.waveSize;
            shaderOptions.wgpMode = pShaderInfo->options.wgpMode;
            if (pShaderInfo->options.allowVaryWaveSize == false)
            {
                // allowVaryWaveSize is disabled, so use -subgroup-size (default 64) to override the wave
                // size for a shader that uses gl_SubgroupSize.
                shaderOptions.subgroupSize = SubgroupSize;
            }
            shaderOptions.waveBreakSize = pShaderInfo->options.waveBreakSize;
#endif

            shaderOptions.loadScalarizerThreshold = 0;
            if (EnableScalarLoad)
            {
                shaderOptions.loadScalarizerThreshold = ScalarThreshold;
            }
#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 33
            if (pShaderInfo->options.enableLoadScalarizer)
            {
                if (pShaderInfo->options.scalarThreshold != 0)
                {
                    shaderOptions.loadScalarizerThreshold = pShaderInfo->options.scalarThreshold;
                }
                else
                {
                    shaderOptions.loadScalarizerThreshold = MaxScalarThreshold;
                }
            }
#endif

            shaderOptions.useSiScheduler = EnableSiScheduler;
#if LLPC_CLIENT_INTERFACE_MAJOR_VERSION >= 28
            shaderOptions.useSiScheduler |= pShaderInfo->options.useSiScheduler;
#endif

            shaderOptions.unrollThreshold = pShaderInfo->options.unrollThreshold;

            pPipeline->SetShaderOptions(static_cast<ShaderStage>(stage), shaderOptions);
        }
    }
}

// =====================================================================================================================
// Give the user data nodes and descriptor range values to the middle-end.
// The user data nodes have been merged so they are the same in each shader stage. Get them from
// the first active stage.
void PipelineContext::SetUserDataInPipeline(
    Pipeline*    pPipeline) const   // [in/out] Middle-end pipeline object
{
    const PipelineShaderInfo* pShaderInfo = nullptr;
    uint32_t stageMask = GetShaderStageMask();
    {
        pShaderInfo = GetPipelineShaderInfo(ShaderStage(countTrailingZeros(stageMask)));
    }
    ArrayRef<ResourceMappingNode> userDataNodes(pShaderInfo->pUserDataNodes,
                                                pShaderInfo->userDataNodeCount);
    ArrayRef<DescriptorRangeValue> descriptorRangeValues(pShaderInfo->pDescriptorRangeValues,
                                                         pShaderInfo->descriptorRangeValueCount);
    pPipeline->SetUserDataNodes(userDataNodes, descriptorRangeValues);
}

// =====================================================================================================================
// Give the graphics pipeline state to the middle-end.
void PipelineContext::SetGraphicsStateInPipeline(
    Pipeline*    pPipeline   // [in/out] Middle-end pipeline object
) const
{
    const auto& inputIaState = static_cast<const GraphicsPipelineBuildInfo*>(GetPipelineBuildInfo())->iaState;
    pPipeline->SetDeviceIndex(inputIaState.deviceIndex);

    InputAssemblyState inputAssemblyState = {};
    // PrimitiveTopology happens to have the same values as the corresponding Vulkan enum.
    inputAssemblyState.topology = static_cast<PrimitiveTopology>(inputIaState.topology);
    inputAssemblyState.patchControlPoints = inputIaState.patchControlPoints;
    inputAssemblyState.disableVertexReuse = inputIaState.disableVertexReuse;
    inputAssemblyState.switchWinding = inputIaState.switchWinding;
    inputAssemblyState.enableMultiView = inputIaState.enableMultiView;

    const auto& inputVpState = static_cast<const GraphicsPipelineBuildInfo*>(GetPipelineBuildInfo())->vpState;
    ViewportState viewportState = {};
    viewportState.depthClipEnable = inputVpState.depthClipEnable;

    const auto& inputRsState = static_cast<const GraphicsPipelineBuildInfo*>(GetPipelineBuildInfo())->rsState;
    RasterizerState rasterizerState = {};
    rasterizerState.rasterizerDiscardEnable = inputRsState.rasterizerDiscardEnable;
    rasterizerState.innerCoverage = inputRsState.innerCoverage;
    rasterizerState.perSampleShading = inputRsState.perSampleShading;
    rasterizerState.numSamples = inputRsState.numSamples;
    rasterizerState.samplePatternIdx = inputRsState.samplePatternIdx;
    rasterizerState.usrClipPlaneMask = inputRsState.usrClipPlaneMask;
    // PolygonMode and CullModeFlags happen to have the same values as their Vulkan equivalents.
    rasterizerState.polygonMode = static_cast<PolygonMode>(inputRsState.polygonMode);
    rasterizerState.cullMode = static_cast<CullModeFlags>(inputRsState.cullMode);
    rasterizerState.frontFaceClockwise = (inputRsState.frontFace != VK_FRONT_FACE_COUNTER_CLOCKWISE);
    rasterizerState.depthBiasEnable = inputRsState.depthBiasEnable;

    pPipeline->SetGraphicsState(inputAssemblyState, viewportState, rasterizerState);
}

// =====================================================================================================================
// Set vertex input descriptions in middle-end Pipeline object
void PipelineContext::SetVertexInputDescriptions(
    Pipeline*   pPipeline   // [in] Pipeline object
) const
{
    auto pVertexInput = static_cast<const GraphicsPipelineBuildInfo*>(GetPipelineBuildInfo())->pVertexInput;
    if (pVertexInput == nullptr)
    {
        return;
    }

    // Gather the bindings.
    SmallVector<VertexInputDescription, 8> bindings;
    for (uint32_t i = 0; i < pVertexInput->vertexBindingDescriptionCount; ++i)
    {
        auto pBinding = &pVertexInput->pVertexBindingDescriptions[i];
        uint32_t idx = pBinding->binding;
        if (idx >= bindings.size())
        {
            bindings.resize(idx + 1);
        }
        bindings[idx].binding = pBinding->binding;
        bindings[idx].stride = pBinding->stride;
        switch (pBinding->inputRate)
        {
        case VK_VERTEX_INPUT_RATE_VERTEX:
            bindings[idx].inputRate = VertexInputRateVertex;
            break;
        case VK_VERTEX_INPUT_RATE_INSTANCE:
            bindings[idx].inputRate = VertexInputRateInstance;
            break;
        default:
            LLPC_NEVER_CALLED();
        }
    }

    // Check for divisors.
    auto pVertexDivisor = FindVkStructInChain<VkPipelineVertexInputDivisorStateCreateInfoEXT>(
        VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_DIVISOR_STATE_CREATE_INFO_EXT,
        pVertexInput->pNext);
    if (pVertexDivisor)
    {
        for (uint32_t i = 0;i < pVertexDivisor->vertexBindingDivisorCount; ++i)
        {
            auto pDivisor = &pVertexDivisor->pVertexBindingDivisors[i];
            if (pDivisor->binding <= bindings.size())
            {
                bindings[pDivisor->binding].inputRate = pDivisor->divisor;
            }
        }
    }

    // Gather the vertex inputs.
    SmallVector<VertexInputDescription, 8> descriptions;
    for (uint32_t i = 0; i < pVertexInput->vertexAttributeDescriptionCount; ++i)
    {
        auto pAttrib = &pVertexInput->pVertexAttributeDescriptions[i];
        if (pAttrib->binding >= bindings.size())
        {
            continue;
        }
        auto pBinding = &bindings[pAttrib->binding];
        if (pBinding->binding != pAttrib->binding)
        {
            continue;
        }

        auto dfmt = BufDataFormatInvalid;
        auto nfmt = BufNumFormatUnorm;
        std::tie(dfmt, nfmt) = MapVkFormat(pAttrib->format);

        if (dfmt != BufDataFormatInvalid)
        {
            descriptions.push_back({
                                      pAttrib->location,
                                      pAttrib->binding,
                                      pAttrib->offset,
                                      pBinding->stride,
                                      dfmt,
                                      nfmt,
                                      pBinding->inputRate,
                                   });
        }
    }

    // Give the vertex input descriptions to the middle-end Pipeline object.
    pPipeline->SetVertexInputDescriptions(descriptions);
}

// =====================================================================================================================
// Map a VkFormat to a {BufDataFormat, BufNumFormat}. Returns BufDataFormatInvalid if the
// VkFormat is not supported for vertex input.
std::pair<BufDataFormat, BufNumFormat> PipelineContext::MapVkFormat(
    VkFormat  format)         // Vulkan API format code
{
    static const struct FormatEntry
    {
#ifndef NDEBUG
        VkFormat       format;
#endif
        BufDataFormat  dfmt;
        BufNumFormat   nfmt;
        uint32_t       validVertexFormat :1;
    }
    formatTable[] =
    {
#ifndef NDEBUG
#define INVALID_FORMAT_ENTRY(format) \
      { format, BufDataFormatInvalid, BufNumFormatUnorm, false }
#define VERTEX_FORMAT_ENTRY(format, dfmt, nfmt) { format, dfmt, nfmt, true }
#else
#define INVALID_FORMAT_ENTRY(format) \
      { BufDataFormatInvalid, BufNumFormatUnorm, false }
#define VERTEX_FORMAT_ENTRY(format, dfmt, nfmt) { dfmt, nfmt, true }
#endif
        INVALID_FORMAT_ENTRY( VK_FORMAT_UNDEFINED),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R4G4_UNORM_PACK8),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R4G4B4A4_UNORM_PACK16),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B4G4R4A4_UNORM_PACK16),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R5G6B5_UNORM_PACK16),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B5G6R5_UNORM_PACK16),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R5G5B5A1_UNORM_PACK16),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B5G5R5A1_UNORM_PACK16),
        INVALID_FORMAT_ENTRY( VK_FORMAT_A1R5G5B5_UNORM_PACK16),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8_UNORM,                   BufDataFormat8,               BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8_SNORM,                   BufDataFormat8,               BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8_USCALED,                 BufDataFormat8,               BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8_SSCALED,                 BufDataFormat8,               BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8_UINT,                    BufDataFormat8,               BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8_SINT,                    BufDataFormat8,               BufNumFormatSint),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8_SRGB),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8_UNORM,                 BufDataFormat8_8,             BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8_SNORM,                 BufDataFormat8_8,             BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8_USCALED,               BufDataFormat8_8,             BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8_SSCALED,               BufDataFormat8_8,             BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8_UINT,                  BufDataFormat8_8,             BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8_SINT,                  BufDataFormat8_8,             BufNumFormatSint),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8G8_SRGB),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8G8B8_UNORM),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8G8B8_SNORM),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8G8B8_USCALED),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8G8B8_SSCALED),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8G8B8_UINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8G8B8_SINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8G8B8_SRGB),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B8G8R8_UNORM),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B8G8R8_SNORM),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B8G8R8_USCALED),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B8G8R8_SSCALED),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B8G8R8_UINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B8G8R8_SINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B8G8R8_SRGB),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8B8A8_UNORM,             BufDataFormat8_8_8_8,         BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8B8A8_SNORM,             BufDataFormat8_8_8_8,         BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8B8A8_USCALED,           BufDataFormat8_8_8_8,         BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8B8A8_SSCALED,           BufDataFormat8_8_8_8,         BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8B8A8_UINT,              BufDataFormat8_8_8_8,         BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R8G8B8A8_SINT,              BufDataFormat8_8_8_8,         BufNumFormatSint),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R8G8B8A8_SRGB),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_B8G8R8A8_UNORM,             BufDataFormat8_8_8_8_Bgra,    BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_B8G8R8A8_SNORM,             BufDataFormat8_8_8_8_Bgra,    BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_B8G8R8A8_USCALED,           BufDataFormat8_8_8_8_Bgra,    BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_B8G8R8A8_SSCALED,           BufDataFormat8_8_8_8_Bgra,    BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_B8G8R8A8_UINT,              BufDataFormat8_8_8_8_Bgra,    BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_B8G8R8A8_SINT,              BufDataFormat8_8_8_8_Bgra,    BufNumFormatSint),
        INVALID_FORMAT_ENTRY( VK_FORMAT_B8G8R8A8_SRGB),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A8B8G8R8_UNORM_PACK32,      BufDataFormat8_8_8_8,         BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A8B8G8R8_SNORM_PACK32,      BufDataFormat8_8_8_8,         BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A8B8G8R8_USCALED_PACK32,    BufDataFormat8_8_8_8,         BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A8B8G8R8_SSCALED_PACK32,    BufDataFormat8_8_8_8,         BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A8B8G8R8_UINT_PACK32,       BufDataFormat8_8_8_8,         BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A8B8G8R8_SINT_PACK32,       BufDataFormat8_8_8_8,         BufNumFormatSint),
        INVALID_FORMAT_ENTRY( VK_FORMAT_A8B8G8R8_SRGB_PACK32),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2R10G10B10_UNORM_PACK32,   BufDataFormat2_10_10_10_Bgra, BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2R10G10B10_SNORM_PACK32,   BufDataFormat2_10_10_10_Bgra, BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2R10G10B10_USCALED_PACK32, BufDataFormat2_10_10_10_Bgra, BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2R10G10B10_SSCALED_PACK32, BufDataFormat2_10_10_10_Bgra, BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2R10G10B10_UINT_PACK32,    BufDataFormat2_10_10_10_Bgra, BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2R10G10B10_SINT_PACK32,    BufDataFormat2_10_10_10_Bgra, BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2B10G10R10_UNORM_PACK32,   BufDataFormat2_10_10_10,      BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2B10G10R10_SNORM_PACK32,   BufDataFormat2_10_10_10,      BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2B10G10R10_USCALED_PACK32, BufDataFormat2_10_10_10,      BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2B10G10R10_SSCALED_PACK32, BufDataFormat2_10_10_10,      BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2B10G10R10_UINT_PACK32,    BufDataFormat2_10_10_10,      BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_A2B10G10R10_SINT_PACK32,    BufDataFormat2_10_10_10,      BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16_UNORM,                  BufDataFormat16,              BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16_SNORM,                  BufDataFormat16,              BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16_USCALED,                BufDataFormat16,              BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16_SSCALED,                BufDataFormat16,              BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16_UINT,                   BufDataFormat16,              BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16_SINT,                   BufDataFormat16,              BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16_SFLOAT,                 BufDataFormat16,              BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16_UNORM,               BufDataFormat16_16,           BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16_SNORM,               BufDataFormat16_16,           BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16_USCALED,             BufDataFormat16_16,           BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16_SSCALED,             BufDataFormat16_16,           BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16_UINT,                BufDataFormat16_16,           BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16_SINT,                BufDataFormat16_16,           BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16_SFLOAT,              BufDataFormat16_16,           BufNumFormatFloat),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R16G16B16_UNORM),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R16G16B16_SNORM),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R16G16B16_USCALED),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R16G16B16_SSCALED),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R16G16B16_UINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R16G16B16_SINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_R16G16B16_SFLOAT),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16B16A16_UNORM,         BufDataFormat16_16_16_16,     BufNumFormatUnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16B16A16_SNORM,         BufDataFormat16_16_16_16,     BufNumFormatSnorm),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16B16A16_USCALED,       BufDataFormat16_16_16_16,     BufNumFormatUscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16B16A16_SSCALED,       BufDataFormat16_16_16_16,     BufNumFormatSscaled),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16B16A16_UINT,          BufDataFormat16_16_16_16,     BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16B16A16_SINT,          BufDataFormat16_16_16_16,     BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R16G16B16A16_SFLOAT,        BufDataFormat16_16_16_16,     BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32_UINT,                   BufDataFormat32,              BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32_SINT,                   BufDataFormat32,              BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32_SFLOAT,                 BufDataFormat32,              BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32G32_UINT,                BufDataFormat32_32,           BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32G32_SINT,                BufDataFormat32_32,           BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32G32_SFLOAT,              BufDataFormat32_32,           BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32G32B32_UINT,             BufDataFormat32_32_32,        BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32G32B32_SINT,             BufDataFormat32_32_32,        BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32G32B32_SFLOAT,           BufDataFormat32_32_32,        BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32G32B32A32_UINT,          BufDataFormat32_32_32_32,     BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32G32B32A32_SINT,          BufDataFormat32_32_32_32,     BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R32G32B32A32_SFLOAT,        BufDataFormat32_32_32_32,     BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64_UINT,                   BufDataFormat64,              BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64_SINT,                   BufDataFormat64,              BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64_SFLOAT,                 BufDataFormat64,              BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64G64_UINT,                BufDataFormat64_64,           BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64G64_SINT,                BufDataFormat64_64,           BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64G64_SFLOAT,              BufDataFormat64_64,           BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64G64B64_UINT,             BufDataFormat64_64_64,        BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64G64B64_SINT,             BufDataFormat64_64_64,        BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64G64B64_SFLOAT,           BufDataFormat64_64_64,        BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64G64B64A64_UINT,          BufDataFormat64_64_64_64,     BufNumFormatUint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64G64B64A64_SINT,          BufDataFormat64_64_64_64,     BufNumFormatSint),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_R64G64B64A64_SFLOAT,        BufDataFormat64_64_64_64,     BufNumFormatFloat),
        VERTEX_FORMAT_ENTRY(  VK_FORMAT_B10G11R11_UFLOAT_PACK32,    BufDataFormat10_11_11,        BufNumFormatFloat),
        INVALID_FORMAT_ENTRY( VK_FORMAT_E5B9G9R9_UFLOAT_PACK32),
        INVALID_FORMAT_ENTRY( VK_FORMAT_D16_UNORM),
        INVALID_FORMAT_ENTRY( VK_FORMAT_X8_D24_UNORM_PACK32),
        INVALID_FORMAT_ENTRY( VK_FORMAT_D32_SFLOAT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_S8_UINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_D16_UNORM_S8_UINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_D24_UNORM_S8_UINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_D32_SFLOAT_S8_UINT),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC1_RGB_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC1_RGB_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC1_RGBA_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC1_RGBA_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC2_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC2_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC3_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC3_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC4_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC4_SNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC5_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC5_SNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC6H_UFLOAT_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC6H_SFLOAT_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC7_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_BC7_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ETC2_R8G8B8_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_EAC_R11_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_EAC_R11_SNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_EAC_R11G11_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_EAC_R11G11_SNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_4x4_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_4x4_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_5x4_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_5x4_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_5x5_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_5x5_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_6x5_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_6x5_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_6x6_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_6x6_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_8x5_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_8x5_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_8x6_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_8x6_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_8x8_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_8x8_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_10x5_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_10x5_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_10x6_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_10x6_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_10x8_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_10x8_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_10x10_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_10x10_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_12x10_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_12x10_SRGB_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_12x12_UNORM_BLOCK),
        INVALID_FORMAT_ENTRY( VK_FORMAT_ASTC_12x12_SRGB_BLOCK),
    };

    BufDataFormat dfmt = BufDataFormatInvalid;
    BufNumFormat nfmt = BufNumFormatUnorm;
    if (format < ArrayRef<FormatEntry>(formatTable).size())
    {
        LLPC_ASSERT(format == formatTable[format].format);
        if (formatTable[format].validVertexFormat)
        {
            dfmt = formatTable[format].dfmt;
            nfmt = formatTable[format].nfmt;
        }
    }
    return { dfmt, nfmt };
}

} // Llpc
