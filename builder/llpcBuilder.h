/*
 ***********************************************************************************************************************
 *
 *  Copyright (c) 2019 Advanced Micro Devices, Inc. All Rights Reserved.
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
 * @file  llpcBuilder.h
 * @brief LLPC header file: declaration of Llpc::Builder interface
 ***********************************************************************************************************************
 */
#pragma once

#include "llpc.h"
#include "llpcDebug.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/AtomicOrdering.h"

namespace llvm
{

class ModulePass;
class PassRegistry;

void initializeBuilderReplayerPass(PassRegistry&);

} // llvm

namespace Llpc
{

class Context;
class PipelineState;

// =====================================================================================================================
// Initialize the pass that gets created by a Builder
inline static void InitializeBuilderPasses(
    llvm::PassRegistry& passRegistry)   // Pass registry
{
    initializeBuilderReplayerPass(passRegistry);
}

// =====================================================================================================================
// The LLPC Builder interface
//
// The Builder interface is used by the frontend to generate IR for LLPC-specific operations. It is
// a subclass of llvm::IRBuilder, so it uses its concept of an insertion point with debug location,
// and it exposes all the IRBuilder methods for building IR. However, unlike IRBuilder, LLPC's
// Builder is designed to have a single instance that contains some other state used during the IR
// building process.
//
// The frontend can use Builder in one of three ways:
// 1. BuilderImpl-only with full pipeline state
// 2. BuilderRecorder with full pipeline state
// 3. Per-shader frontend compilation (This is proposed but currently unsupported and untested.)
//
// 1. BuilderImpl-only with full pipeline state
//
//    This is used where the frontend has full pipeline state, and it wants to generate IR for LLPC
//    operations directly, instead of recording it in the frontend and then replaying the recorded
//    calls at the start of the middle-end.
//
//    The frontend does this:
//
//    * Create an instance of BuilderImpl.
//    * Create an IR module per shader stage.
//    * Give the pipeline state to the Builder (Builder::SetUserDataNodes()).
//    * Populate the per-shader-stage IR modules, using Builder::Create* calls to generate the IR
//      for LLPC operations.
//    * After finishing, call Builder::Link() to link the per-stage IR modules into a single
//      pipeline module.
//    * Run middle-end passes on it.
//
// 2. BuilderRecorder with full pipeline state
//
//    This is also used where the frontend has full pipeline state, but it wants to record its
//    Builder::Create* calls such that they get replayed (and generated into normal IR) as the first
//    middle-end pass.
//
//    The frontend's actions are pretty much the same as in (1):
//
//    * Create an instance of BuilderRecorder.
//    * Create an IR module per shader stage.
//    * Give the pipeline state to the Builder (Builder::SetUserDataNodes()).
//    * Populate the per-shader-stage IR modules, using Builder::Create* calls to generate the IR
//      for LLPC operations.
//    * After finishing, call Builder::Link() to link the per-stage IR modules into a single
//      pipeline module.
//    * Run middle-end passes on it, starting with BuilderReplayer to replay all the recorded
//      Builder::Create* calls into its own instance of BuilderImpl (but with a single pipeline IR
//      module).
//
//    With this scheme, the intention is that the whole-pipeline IR module after linking is a
//    representation of the pipeline. For testing purposes, the IR module could be output to a .ll
//    file, and later read in and compiled through the middle-end passes and backend to ISA.
//    However, that is not supported yet, as there is still some outside-IR state at that point.
//
// 3. Per-shader frontend compilation (This is proposed but currently unsupported and untested.)
//
//    The frontend can compile a single shader with no pipeline state available using
//    BuilderRecorder, without linking at the end, giving a shader IR module containing recorded
//    llpc.call.* calls but no pipeline state.
//
//    The frontend does this:
//
//    * Per shader:
//      - Create an instance of BuilderRecorder.
//      - Create an IR module per shader stage.
//      - Populate the per-shader-stage IR modules, using Builder::Create* calls to generate the IR
//        for LLPC operations.
//    * Then, later on, bring the shader IR modules together, and link them with Builder::Link()
//      into a single pipeline IR module.
//    * Give the pipeline state to the Builder (Builder::SetUserDataNodes()).
//    * Run middle-end passes on it, starting with BuilderReplayer to replay all the recorded
//      Builder::Create* calls into its own instance of BuilderImpl (but with a single pipeline IR
//      module).
//
class Builder : public llvm::IRBuilder<>
{
public:
    // The group arithmetic operations the builder can consume.
    // NOTE: We rely on casting this implicitly to an integer, so we cannot use an enum class.
    enum GroupArithOp
    {
        IAdd = 0,
        FAdd,
        IMul,
        FMul,
        SMin,
        UMin,
        FMin,
        SMax,
        UMax,
        FMax,
        And,
        Or,
        Xor
    };

    virtual ~Builder();

    // Create the BuilderImpl. In this implementation, each Builder call writes its IR immediately.
    static Builder* CreateBuilderImpl(llvm::LLVMContext& context);

    // Create the BuilderRecorder. In this implementation, each Builder call gets recorded (by inserting
    // an llpc.call.* call). The user then replays the Builder calls by running the pass created by
    // CreateBuilderReplayer. Setting wantReplay=false makes CreateBuilderReplayer return nullptr.
    static Builder* CreateBuilderRecorder(llvm::LLVMContext& context, bool wantReplay);

    // Create the BuilderImpl or BuilderRecorder, depending on -use-builder-recorder option
    static Builder* Create(llvm::LLVMContext& context);

    // If this is a BuilderRecorder, create the BuilderReplayer pass, otherwise return nullptr.
    virtual llvm::ModulePass* CreateBuilderReplayer() { return nullptr; }

    // Set the resource mapping nodes for the pipeline. "nodes" describes the user data
    // supplied to the shader as a hierarchical table (max two levels) of descriptors.
    // "immutableDescs" contains descriptors (currently limited to samplers), whose values are hard
    // coded by the application. Each one is a duplicate of one in "nodes". A use of one of these immutable
    // descriptors in the applicable Create* method is converted directly to the constant value.
    //
    // If using a BuilderImpl, this method must be called before any Create* methods.
    // If using a BuilderRecorder, it can be delayed until after linking.
    void SetUserDataNodes(
        llvm::ArrayRef<ResourceMappingNode>   nodes,            // The resource mapping nodes
        llvm::ArrayRef<DescriptorRangeValue>  rangeValues);     // The descriptor range values

    // Set the current shader stage.
    void SetShaderStage(ShaderStage stage) { m_shaderStage = stage; }

    // Link the individual shader modules into a single pipeline module. The frontend must have
    // finished calling Builder::Create* methods and finished building the IR. In the case that
    // there are multiple shader modules, they are all freed by this call, and the linked pipeline
    // module is returned. If there is a single shader module, this might instead just return that.
    // Before calling this, each shader module needs to have one global function for the shader
    // entrypoint, then all other functions with internal linkage.
    // Returns the pipeline module, or nullptr on link failure.
    virtual llvm::Module* Link(
        llvm::ArrayRef<llvm::Module*> modules);     // Array of modules indexed by shader stage, with nullptr entry
                                                    //  for any stage not present in the pipeline

    // -----------------------------------------------------------------------------------------------------------------
    // Descriptor operations

    // Get the type of pointer returned by CreateLoadBufferDesc.
    llvm::PointerType* GetBufferDescTy(llvm::Type* pPointeeTy);

    // Create a load of a buffer descriptor.
    virtual llvm::Value* CreateLoadBufferDesc(
        uint32_t            descSet,            // Descriptor set
        uint32_t            binding,            // Descriptor binding
        llvm::Value*        pDescIndex,         // [in] Descriptor index
        bool                isNonUniform,       // Whether the descriptor index is non-uniform
        llvm::Type*         pPointeeTy,         // [in] Type that the returned pointer should point to.
        const llvm::Twine&  instName = "") = 0; // [in] Name to give instruction(s)

    // Add index onto pointer to image/sampler/texelbuffer/F-mask array of descriptors.
    virtual llvm::Value* CreateIndexDescPtr(
        llvm::Value*        pDescPtr,           // [in] Descriptor pointer, as returned by this function or one of
                                                //    the CreateGet*DescPtr methods
        llvm::Value*        pIndex,             // [in] Index value
        bool                isNonUniform,       // Whether the descriptor index is non-uniform
        const llvm::Twine&  instName = "") = 0; // [in] Name to give instruction(s)

    // Load image/sampler/texelbuffer/F-mask descriptor from pointer.
    // Returns <8 x i32> descriptor for image or F-mask, or <4 x i32> descriptor for sampler or texel buffer.
    virtual llvm::Value* CreateLoadDescFromPtr(
        llvm::Value*        pDescPtr,           // [in] Descriptor pointer, as returned by CreateIndexDesc or one of
                                                //    the CreateGet*DescPtr methods
        const llvm::Twine&  instName = "") = 0; // [in] Name to give instruction(s)

    // Get the type of an image descriptor.
    llvm::VectorType* GetImageDescTy();

    // Get the type of an F-mask descriptor.
    llvm::VectorType* GetFmaskDescTy();

    // Get the type of a sampler descriptor.
    llvm::VectorType* GetSamplerDescTy();

    // Get the type of a texel buffer descriptor.
    llvm::VectorType* GetTexelBufferDescTy();

    // Get the type of pointer to image or F-mask descriptor, as returned by CreateGetImageDescPtr.
    // The type is in fact a struct containing the actual pointer plus a stride in dwords.
    // Currently the stride is not set up or used by anything; in the future, CreateGet*DescPtr calls will
    // set up the stride, and CreateIndexDescPtr will use it.
    llvm::Type* GetImageDescPtrTy();

    // Get the type of pointer to F-mask descriptor, as returned by CreateGetFmaskDescPtr.
    // The type is in fact a struct containing the actual pointer plus a stride in dwords.
    // Currently the stride is not set up or used by anything; in the future, CreateGet*DescPtr calls will
    // set up the stride, and CreateIndexDescPtr will use it.
    llvm::Type* GetFmaskDescPtrTy();

    // Get the type of pointer to texel buffer descriptor, as returned by CreateGetTexelBufferDescPtr.
    // The type is in fact a struct containing the actual pointer plus a stride in dwords.
    // Currently the stride is not set up or used by anything; in the future, CreateGet*DescPtr calls will
    // set up the stride, and CreateIndexDescPtr will use it.
    llvm::Type* GetTexelBufferDescPtrTy();

    // Get the type of pointer to sampler descriptor, as returned by CreateGetSamplerDescPtr.
    // The type is in fact a struct containing the actual pointer plus a stride in dwords.
    // Currently the stride is not set up or used by anything; in the future, CreateGet*DescPtr calls will
    // set up the stride, and CreateIndexDescPtr will use it.
    llvm::Type* GetSamplerDescPtrTy();

    // Create a pointer to sampler descriptor. Returns a value of the type returned by GetSamplerDescPtrTy.
    virtual llvm::Value* CreateGetSamplerDescPtr(
        uint32_t            descSet,          // Descriptor set
        uint32_t            binding,          // Descriptor binding
        const llvm::Twine&  instName = ""     // [in] Name to give instruction(s)
    ) = 0;

    // Create a pointer to image descriptor. Returns a value of the type returned by GetImageDescPtrTy.
    virtual llvm::Value* CreateGetImageDescPtr(
        uint32_t            descSet,          // Descriptor set
        uint32_t            binding,          // Descriptor binding
        const llvm::Twine&  instName = ""     // [in] Name to give instruction(s)
    ) = 0;

    // Create a pointer to texel buffer descriptor. Returns a value of the type returned by GetTexelBufferDescPtrTy.
    virtual llvm::Value* CreateGetTexelBufferDescPtr(
        uint32_t            descSet,          // Descriptor set
        uint32_t            binding,          // Descriptor binding
        const llvm::Twine&  instName = ""     // [in] Name to give instruction(s)
    ) = 0;

    // Create a load of a F-mask descriptor. Returns a value of the type returned by GetFmaskDescPtrTy.
    virtual llvm::Value* CreateGetFmaskDescPtr(
        uint32_t            descSet,          // Descriptor set
        uint32_t            binding,          // Descriptor binding
        const llvm::Twine&  instName = ""     // [in] Name to give instruction(s)
    ) = 0;

    // Create a load of the push constants pointer.
    // This returns a pointer to the ResourceMappingNodeType::PushConst resource in the top-level user data table.
    virtual llvm::Value* CreateLoadPushConstantsPtr(
        llvm::Type*         pPushConstantsTy,   // [in] Type that the returned pointer will point to
        const llvm::Twine&  instName = "") = 0; // [in] Name to give instruction(s)

    // Create a buffer length query based on the specified descriptor.
    virtual llvm::Value* CreateGetBufferDescLength(
        llvm::Value* const  pBufferDesc,        // [in] The buffer descriptor to query.
        const llvm::Twine&  instName = "") = 0; // [in] Name to give instruction(s)

    // -----------------------------------------------------------------------------------------------------------------
    // Image operations

    // Possible values for dimension argument for image methods.
    enum
    {
        Dim1D = 0,            // Coordinate: x
        Dim2D = 1,            // Coordinate: x, y
        Dim3D = 2,            // Coordinate: x, y, z
        DimCube = 3,          // Coordinate: x, y, face
        Dim1DArray = 4,       // Coordinate: x, slice
        Dim2DArray = 5,       // Coordinate: x, y, slice
        Dim2DMsaa = 6,        // Coordinate: x, y, fragid
        Dim2DArrayMsaa = 7,   // Coordinate: x, y, slice, fragid
        DimCubeArray = 8,     // Coordinate: x, y, face, slice (despite both SPIR-V and ISA
                              //    combining face and slice into one component)
    };

    // Get the number of coordinates for the specified dimension argument.
    static uint32_t GetImageNumCoords(
        uint32_t dim)   // Image dimension
    {
        switch (dim)
        {
        case Dim1D: return 1;
        case Dim2D: return 2;
        case Dim3D: return 3;
        case DimCube: return 3;
        case Dim1DArray: return 2;
        case Dim2DArray: return 3;
        case Dim2DMsaa: return 3;
        case Dim2DArrayMsaa: return 4;
        case DimCubeArray: return 4;
        }
        LLPC_NEVER_CALLED();
        return 0;
    }

    // Get the number of components of a size query for the specified dimension argument.
    static uint32_t GetImageQuerySizeComponentCount(
        uint32_t dim)   // Image dimension
    {
        switch (dim)
        {
        case Dim1D: return 1;
        case Dim2D: return 2;
        case Dim3D: return 3;
        case DimCube: return 2;
        case Dim1DArray: return 2;
        case Dim2DArray: return 3;
        case Dim2DMsaa: return 2;
        case Dim2DArrayMsaa: return 3;
        case DimCubeArray: return 3;
        }
        LLPC_NEVER_CALLED();
        return 0;
    }

    // Bit settings in flags argument for image methods.
    enum
    {
        ImageFlagCoherent = 1,              // Coherent memory access
        ImageFlagVolatile = 2,              // Volatile memory access
        ImageFlagSignedResult = 4,          // For a gather with integer result, whether it is signed
        ImageFlagNonUniformImage = 8,       // Whether the image descriptor is non-uniform
        ImageFlagNonUniformSampler = 0x10,  // Whether the sampler descriptor is non-uniform
        ImageFlagAddFragCoord = 0x20,       // Add FragCoord (converted to signed int) on to coordinate x,y.
                                            // Image load, store and atomic only.
        ImageFlagUseViewIndex = 0x40,       // Use ViewIndex as coordinate z. Image load, store and atomic only.
    };

    // Address array indices for image sample and gather methods. Where an optional entry is missing (either
    // nullptr, or the array is not long enough for it), then it assumes a default value.
    enum
    {
        ImageAddressIdxCoordinate = 0,    // Coordinate - a scalar or vector of float or half exactly as wide as
                                          //    returned by GetImageNumCoords(dim)
        ImageAddressIdxProjective = 1,    // Projective coordinate - divided into each coordinate (image sample only)
                                          //  (optional; default no projective divide)
        ImageAddressIdxComponent = 2,     // Component - constant i32 component for gather
        ImageAddressIdxDerivativeX = 3,   // X derivative - vector of float or half with number of coordinates
                                          //  excluding array slice (optional; default is to use
                                          //  implicit derivatives).
        ImageAddressIdxDerivativeY = 4,   // Y derivative - vector of float or half with number of coordinates
                                          //  excluding array slice (optional; default is to use
                                          //  implicit derivatives).
        ImageAddressIdxLod = 5,           // float level of detail (optional; default is to use
                                          //  implicit computed LOD)
        ImageAddressIdxLodBias = 6,       // float bias to add to the computed LOD (optional;
                                          //  default 0.0)
        ImageAddressIdxLodClamp = 7,      // float value to clamp LOD to (optional; default
                                          //  no clamping)
        ImageAddressIdxOffset = 8,        // Offset to add to coordinates - scalar or vector of i32, padded with 0s
                                          //  if not wide enough (optional; default all 0s). Alternatively, for
                                          //  independent offsets in a gather, a 4-array of the same, which is
                                          //  implemented as four separate gather instructions
        ImageAddressIdxZCompare = 9,      // float Z-compare value (optional; default no Z-compare)
        ImageAddressCount = 10            // All image address indices are less than this
    };

    // Atomic operation, for use in CreateImageAtomic.
    enum
    {
        ImageAtomicSwap = 0,    // Atomic operation: swap
        ImageAtomicAdd = 2,     // Atomic operation: add
        ImageAtomicSub = 3,     // Atomic operation: subtract
        ImageAtomicSMin = 4,    // Atomic operation: signed minimum
        ImageAtomicUMin = 5,    // Atomic operation: unsigned minimum
        ImageAtomicSMax = 6,    // Atomic operation: signed maximum
        ImageAtomicUMax = 7,    // Atomic operation: unsigned maximum
        ImageAtomicAnd = 8,     // Atomic operation: and
        ImageAtomicOr = 9,      // Atomic operation: or
        ImageAtomicXor = 10     // Atomic operation: xor
    };

    // Create an image load.
    virtual llvm::Value* CreateImageLoad(
        llvm::Type*                   pResultTy,          // [in] Result type
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::Value*                  pImageDesc,         // [in] Image descriptor or texel buffer descriptor.
        llvm::Value*                  pCoord,             // [in] Coordinates: scalar or vector i32, exactly right width
        llvm::Value*                  pMipLevel,          // [in] Mipmap level if doing load_mip, otherwise nullptr
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create an image load with fmask. Dim must be 2DMsaa or 2DArrayMsaa. If the F-mask descriptor has a valid
    // format field, then it reads "fmask_texel_R", the R component of the texel read from the given coordinates
    // in the F-mask image, and calculates the sample number to use as the sample'th nibble (where sample=0 means
    // the least significant nibble) of fmask_texel_R. If the F-mask descriptor has an invalid format, then it
    // just uses the supplied sample number. The calculated sample is then appended to the supplied coordinates
    // for a normal image load.
    virtual llvm::Value* CreateImageLoadWithFmask(
        llvm::Type*                   pResultTy,          // [in] Result type
        uint32_t                      dim,                // Image dimension, 2DMsaa or 2DArrayMsaa
        uint32_t                      flags,              // ImageFlag* flags
        llvm::Value*                  pImageDesc,         // [in] Image descriptor
        llvm::Value*                  pFmaskDesc,         // [in] Fmask descriptor
        llvm::Value*                  pCoord,             // [in] Coordinates: scalar or vector i32, exactly right
                                                          //    width for given dimension excluding sample
        llvm::Value*                  pSampleNum,         // [in] Sample number, i32
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create an image store.
    virtual llvm::Value* CreateImageStore(
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::Value*                  pImageDesc,         // [in] Image descriptor or texel buffer descriptor
        llvm::Value*                  pCoord,             // [in] Coordinates: scalar or vector i32, exactly right width
        llvm::Value*                  pMipLevel,          // [in] Mipmap level if doing store_mip, otherwise nullptr
        llvm::Value*                  pTexel,             // [in] Texel value to store; v4i16, v4i32, v4f16 or v4f32
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create an image sample.
    // The return type is specified by pResultTy as follows:
    // * If it is a struct, then the method generates a TFE (texel fail enable) operation. The first field is the
    //   texel type, and the second field is i32, where bit 0 is the TFE bit. Otherwise, the return type is the texel
    //   type.
    // * If the ZCompare address component is supplied, then the texel type is the scalar texel component
    //   type. Otherwise the texel type is a 4-vector of the texel component type.
    // * The texel component type is i32, f16 or f32.
    virtual llvm::Value* CreateImageSample(
        llvm::Type*                   pResultTy,          // [in] Result type
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::Value*                  pImageDesc,         // [in] Image descriptor
        llvm::Value*                  pSamplerDesc,       // [in] Sampler descriptor
        llvm::ArrayRef<llvm::Value*>  address,            // Address and other arguments
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create an image gather.
    // The return type is specified by pResultTy as follows:
    // * If it is a struct, then the method generates a TFE (texel fail enable) operation. The first field is the
    //   texel type, and the second field is i32, where bit 0 is the TFE bit. Otherwise, the return type is the texel
    //   type.
    // * The texel type is a 4-vector of the texel component type, which is i32, f16 or f32.
    virtual llvm::Value* CreateImageGather(
        llvm::Type*                   pResultTy,          // [in] Result type
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::Value*                  pImageDesc,         // [in] Image descriptor
        llvm::Value*                  pSamplerDesc,       // [in] Sampler descriptor
        llvm::ArrayRef<llvm::Value*>  address,            // Address and other arguments
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create an image atomic operation other than compare-and-swap. An add of +1 or -1, or a sub
    // of -1 or +1, is generated as inc or dec. Result type is the same as the input value type.
    // Normally pImageDesc is an image descriptor, as returned by CreateLoadImageDesc, and this method
    // creates an image atomic instruction. But pImageDesc can instead be a texel buffer descriptor, as
    // returned by CreateLoadTexelBufferDesc, in which case the method creates a buffer atomic instruction.
    virtual llvm::Value* CreateImageAtomic(
        uint32_t                      atomicOp,           // Atomic op to create
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::AtomicOrdering          ordering,           // Atomic ordering
        llvm::Value*                  pImageDesc,         // [in] Image descriptor or texel buffer descriptor
        llvm::Value*                  pCoord,             // [in] Coordinates: scalar or vector i32, exactly right width
        llvm::Value*                  pInputValue,        // [in] Input value: i32
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create an image atomic compare-and-swap.
    // Normally pImageDesc is an image descriptor, as returned by CreateLoadImageDesc, and this method
    // creates an image atomic instruction. But pImageDesc can instead be a texel buffer descriptor, as
    // returned by CreateLoadTexelBufferDesc, in which case the method creates a buffer atomic instruction.
    virtual llvm::Value* CreateImageAtomicCompareSwap(
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::AtomicOrdering          ordering,           // Atomic ordering
        llvm::Value*                  pImageDesc,         // [in] Image descriptor or texel buffer descriptor
        llvm::Value*                  pCoord,             // [in] Coordinates: scalar or vector i32, exactly right width
        llvm::Value*                  pInputValue,        // [in] Input value: i32
        llvm::Value*                  pComparatorValue,   // [in] Value to compare against: i32
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create a query of the number of mipmap levels in an image. Returns an i32 value.
    virtual llvm::Value* CreateImageQueryLevels(
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::Value*                  pImageDesc,         // [in] Image descriptor or texel buffer descriptor
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create a query of the number of samples in an image. Returns an i32 value.
    virtual llvm::Value* CreateImageQuerySamples(
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::Value*                  pImageDesc,         // [in] Image descriptor or texel buffer descriptor
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create a query of size of an image at the specified LOD.
    // Returns an i32 scalar or vector of the width given by GetImageQuerySizeComponentCount.
    virtual llvm::Value* CreateImageQuerySize(
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::Value*                  pImageDesc,         // [in] Image descriptor or texel buffer descriptor
        llvm::Value*                  pLod,               // [in] LOD
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // Create a get of the LOD that would be used for an image sample with the given coordinates
    // and implicit LOD. Returns a v2f32 containing the layer number and the implicit level of
    // detail relative to the base level.
    virtual llvm::Value* CreateImageGetLod(
        uint32_t                      dim,                // Image dimension
        uint32_t                      flags,              // ImageFlag* flags
        llvm::Value*                  pImageDesc,         // [in] Image descriptor
        llvm::Value*                  pSamplerDesc,       // [in] Sampler descriptor
        llvm::Value*                  pCoord,             // [in] Coordinates: scalar or vector f32, exactly right
                                                          //    width without array layer
        const llvm::Twine&            instName = "") = 0; // [in] Name to give instruction(s)

    // -----------------------------------------------------------------------------------------------------------------
    // Matrix operations

    // Create a matrix transpose.
    virtual llvm::Value* CreateTransposeMatrix(
        llvm::Value* const pMatrix,            // [in] The matrix to transpose
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // -----------------------------------------------------------------------------------------------------------------
    // Miscellaneous operations

    // Create a "kill". Only allowed in a fragment shader.
    virtual llvm::Instruction* CreateKill(
        const llvm::Twine&  instName = "") = 0; // [in] Name to give instruction(s)

    // Create a "readclock".
    virtual llvm::Instruction* CreateReadClock(
        bool                realtime,           // Whether to read real-time clock counter
        const llvm::Twine&  instName = "") = 0; // [in] Name to give instruction(s)

    // Get the LLPC context. This overrides the IRBuilder method that gets the LLVM context.
    Llpc::Context& getContext() const;

    // -----------------------------------------------------------------------------------------------------------------
    // Subgroup operations

    // Create a get subgroup size query.
    virtual llvm::Value* CreateGetSubgroupSize(
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup elect.
    virtual llvm::Value* CreateSubgroupElect(
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup all.
    virtual llvm::Value* CreateSubgroupAll(
        llvm::Value* const pValue,             // [in] The value to compare
        bool               wqm = false,        // Executed in WQM (whole quad mode)
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup any
    virtual llvm::Value* CreateSubgroupAny(
        llvm::Value* const pValue,             // [in] The value to compare
        bool               wqm = false,        // Executed in WQM (whole quad mode)
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup all equal.
    virtual llvm::Value* CreateSubgroupAllEqual(
        llvm::Value* const pValue,             // [in] The value to compare
        bool               wqm = false,        // Executed in WQM (whole quad mode)
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup broadcast.
    virtual llvm::Value* CreateSubgroupBroadcast(
        llvm::Value* const pValue,             // [in] The value to broadcast
        llvm::Value* const pIndex,             // [in] The index to broadcast from
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup broadcast first.
    virtual llvm::Value* CreateSubgroupBroadcastFirst(
        llvm::Value* const pValue,             // [in] The value to broadcast
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup ballot.
    virtual llvm::Value* CreateSubgroupBallot(
        llvm::Value* const pValue,             // [in] The value to contribute
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup inverse ballot.
    virtual llvm::Value* CreateSubgroupInverseBallot(
        llvm::Value* const pValue,             // [in] The ballot value
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup ballot bit extract.
    virtual llvm::Value* CreateSubgroupBallotBitExtract(
        llvm::Value* const pValue,             // [in] The ballot value
        llvm::Value* const pIndex,             // [in] The index to extract from the ballot
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup ballot bit count.
    virtual llvm::Value* CreateSubgroupBallotBitCount(
        llvm::Value* const pValue,             // [in] The ballot value
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup ballot inclusive bit count.
    virtual llvm::Value* CreateSubgroupBallotInclusiveBitCount(
        llvm::Value* const pValue,             // [in] The ballot value
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup ballot exclusive bit count.
    virtual llvm::Value* CreateSubgroupBallotExclusiveBitCount(
        llvm::Value* const pValue,             // [in] The ballot value
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup ballot find least significant bit.
    virtual llvm::Value* CreateSubgroupBallotFindLsb(
        llvm::Value* const pValue,             // [in] The ballot value
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup ballot find most significant bit.
    virtual llvm::Value* CreateSubgroupBallotFindMsb(
        llvm::Value* const pValue,             // [in] The ballot value
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup shuffle.
    virtual llvm::Value* CreateSubgroupShuffle(
        llvm::Value* const pValue,             // [in] The value to shuffle
        llvm::Value* const pIndex,             // [in] The index to shuffle from
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup shuffle xor.
    virtual llvm::Value* CreateSubgroupShuffleXor(
        llvm::Value* const pValue,             // [in] The value to shuffle
        llvm::Value* const pMask,              // [in] The mask to shuffle with
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup shuffle up.
    virtual llvm::Value* CreateSubgroupShuffleUp(
        llvm::Value* const pValue,             // [in] The value to shuffle
        llvm::Value* const pDelta,             // [in] The delta to shuffle up to
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup shuffle down.
    virtual llvm::Value* CreateSubgroupShuffleDown(
        llvm::Value* const pValue,             // [in] The value to shuffle
        llvm::Value* const pDelta,             // [in] The delta to shuffle down to
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup clustered reduction.
    virtual llvm::Value* CreateSubgroupClusteredReduction(
        GroupArithOp       groupArithOp,       // The group arithmetic operation to perform
        llvm::Value* const pValue,             // [in] The value to perform on
        llvm::Value* const pClusterSize,       // [in] The cluster size
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup clustered inclusive scan.
    virtual llvm::Value* CreateSubgroupClusteredInclusive(
        GroupArithOp       groupArithOp,       // The group arithmetic operation to perform
        llvm::Value* const pValue,             // [in] The value to perform on
        llvm::Value* const pClusterSize,       // [in] The cluster size
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup clustered exclusive scan.
    virtual llvm::Value* CreateSubgroupClusteredExclusive(
        GroupArithOp       groupArithOp,       // The group arithmetic operation to perform
        llvm::Value* const pValue,             // [in] The value to perform on
        llvm::Value* const pClusterSize,       // [in] The cluster size
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup quad broadcast.
    virtual llvm::Value* CreateSubgroupQuadBroadcast(
        llvm::Value* const pValue,             // [in] The value to broadcast
        llvm::Value* const pIndex,             // [in] the index within the quad to broadcast from
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup quad swap horizontal.
    virtual llvm::Value* CreateSubgroupQuadSwapHorizontal(
        llvm::Value* const pValue,             // [in] The value to swap
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup quad swap vertical.
    virtual llvm::Value* CreateSubgroupQuadSwapVertical(
        llvm::Value* const pValue,             // [in] The value to swap
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup quad swap diagonal.
    virtual llvm::Value* CreateSubgroupQuadSwapDiagonal(
        llvm::Value* const pValue,             // [in] The value to swap
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup swizzle quad.
    virtual llvm::Value* CreateSubgroupSwizzleQuad(
        llvm::Value* const pValue,             // [in] The value to swizzle.
        llvm::Value* const pOffset,            // [in] The value to specify the swizzle offsets.
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup swizzle masked.
    virtual llvm::Value* CreateSubgroupSwizzleMask(
        llvm::Value* const pValue,             // [in] The value to swizzle.
        llvm::Value* const pMask,              // [in] The value to specify the swizzle masks.
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup write invocation.
    virtual llvm::Value* CreateSubgroupWriteInvocation(
        llvm::Value* const pInputValue,        // [in] The value to return for all but one invocations.
        llvm::Value* const pWriteValue,        // [in] The value to return for one invocation.
        llvm::Value* const pIndex,             // [in] The index of the invocation that gets the write value.
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // Create a subgroup mbcnt.
    virtual llvm::Value* CreateSubgroupMbcnt(
        llvm::Value* const pMask,              // [in] The mask to mbcnt with.
        const llvm::Twine& instName = "") = 0; // [in] Name to give instruction(s)

    // -----------------------------------------------------------------------------------------------------------------

protected:
    Builder(llvm::LLVMContext& context);

    // -----------------------------------------------------------------------------------------------------------------

    ShaderStage     m_shaderStage     = ShaderStageInvalid; // Current shader stage being built.
    PipelineState*  m_pPipelineState  = nullptr;            // Pipeline state

    llvm::Type* GetTransposedMatrixTy(
        llvm::Type* const pMatrixType) const; // [in] The matrix type to tranpose

    typedef llvm::Value* (*PFN_MapToInt32Func)(Builder&                     builder,
                                               llvm::ArrayRef<llvm::Value*> mappedArgs,
                                               llvm::ArrayRef<llvm::Value*> passthroughArgs);

    // Create a call that'll map the massage arguments to an i32 type (for functions that only take i32).
    llvm::Value* CreateMapToInt32(
        PFN_MapToInt32Func           pfnMapFunc,       // [in] Pointer to the function to call on each i32.
        llvm::ArrayRef<llvm::Value*> mappedArgs,       // The arguments to massage into an i32 type.
        llvm::ArrayRef<llvm::Value*> passthroughArgs); // The arguments to pass-through without massaging.
private:
    LLPC_DISALLOW_DEFAULT_CTOR(Builder)
    LLPC_DISALLOW_COPY_AND_ASSIGN(Builder)
};

// Create BuilderReplayer pass
llvm::ModulePass* CreateBuilderReplayer(Builder* pBuilder);

} // Llpc
