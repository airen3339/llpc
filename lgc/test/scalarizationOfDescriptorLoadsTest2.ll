; NOTE: Assertions have been autogenerated by tool/update_llpc_test_checks.py UTC_ARGS: --tool lgc
; RUN: lgc -mcpu=gfx1010 -print-after=lgc-builder-replayer -o - %s 2>&1 | FileCheck --check-prefixes=CHECK %s

; This test checks how scalarization works if we have a @lgc.create.image.store call.
; Here, we have to emit amdgcn.waterfall.last.use instead of amdgcn.waterfall.end.

source_filename = "lgcPipeline"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-p7:160:256:256:32-p8:128:128-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7:8-p32:32:32"
target triple = "amdgcn--amdpal"

; Function Attrs: nounwind
define dllexport spir_func void @lgc.shader.VS.main() local_unnamed_addr #0 !spirv.ExecutionModel !14 !lgc.shaderstage !15 {
.entry:
  %i = call <4 x i32> (...) @lgc.create.read.generic.input.v4i32(i32 2, i32 0, i32 0, i32 0, i32 0, i32 poison)
  %.fr = freeze <4 x i32> %i
  %__llpc_input_proxy_4.0.vec.extract = extractelement <4 x i32> %.fr, i64 0
  %i1 = call ptr addrspace(4) (...) @lgc.create.get.desc.ptr.p4(i32 4, i32 4, i64 0, i32 0)
  %i2 = call i32 (...) @lgc.create.get.desc.stride.i32(i32 4, i32 4, i64 0, i32 0)
  %i3 = mul i32 %__llpc_input_proxy_4.0.vec.extract, %i2
  %i4 = sext i32 %i3 to i64
  %i5 = getelementptr i8, ptr addrspace(4) %i1, i64 %i4
  %i6 = load <4 x i32>, ptr addrspace(4) %i5, align 16, !invariant.load !16
  %i7 = getelementptr i8, ptr addrspace(4) %i1, i64 %i4
  %i8 = load <4 x i32>, ptr addrspace(4) %i7, align 16, !invariant.load !16
  call void (...) @lgc.create.image.store(<4 x i32> %i8, i32 0, i32 8, <4 x i32> %i6, i32 1)
  ret void
}

; Function Attrs: nounwind willreturn memory(read)
declare <4 x i32> @lgc.create.read.generic.input.v4i32(...) local_unnamed_addr #1

; Function Attrs: nounwind memory(none)
declare ptr addrspace(4) @lgc.create.get.desc.ptr.p4(...) local_unnamed_addr #2

; Function Attrs: nounwind memory(none)
declare i32 @lgc.create.get.desc.stride.i32(...) local_unnamed_addr #2

; Function Attrs: nounwind memory(write)
declare void @lgc.create.image.store(...) local_unnamed_addr #3

attributes #0 = { nounwind "denormal-fp-math-f32"="preserve-sign" }
attributes #1 = { nounwind willreturn memory(read) }
attributes #2 = { nounwind memory(none) }
attributes #3 = { nounwind memory(write) }

!lgc.client = !{!0}
!lgc.options = !{!1}
!lgc.options.VS = !{!2}
!lgc.options.FS = !{!3}
!lgc.user.data.nodes = !{!4, !5, !6, !7}
!lgc.vertex.inputs = !{!8, !9, !10}
!lgc.color.export.formats = !{!11}
!lgc.rasterizer.state = !{!12}
!amdgpu.pal.metadata.msgpack = !{!13}

!0 = !{!"Vulkan"}
!1 = !{i32 -1055878566, i32 -1332805290, i32 1045905781, i32 -589165353, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1, i32 256, i32 256, i32 -1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 16777216}
!2 = !{i32 1639417258, i32 -1495429105, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 64, i32 0, i32 0, i32 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 20, i32 1800, i32 0, i32 0, i32 1}
!3 = !{i32 -1409621709, i32 -171549995, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 64, i32 64, i32 0, i32 0, i32 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 20, i32 1800, i32 0, i32 0, i32 1}
!4 = !{!"DescriptorTableVaPtr", i32 7, i32 66, i32 0, i32 1, i32 1}
!5 = !{!"DescriptorTexelBuffer", i32 4, i32 66, i32 0, i32 16384, i64 0, i32 0, i32 4}
!6 = !{!"StreamOutTableVaPtr", i32 11, i32 4, i32 1, i32 1, i32 0}
!7 = !{!"IndirectUserDataVaPtr", i32 8, i32 2, i32 2, i32 1, i32 4}
!8 = !{i32 0, i32 0, i32 0, i32 40, i32 14, i32 7}
!9 = !{i32 1, i32 0, i32 16, i32 40, i32 11, i32 7}
!10 = !{i32 2, i32 0, i32 24, i32 40, i32 14, i32 5}
!11 = !{i32 14, i32 7, i32 0, i32 0, i32 15}
!12 = !{i32 0, i32 0, i32 0, i32 1}
!13 = !{!"\82\B0amdpal.pipelines\91\83\B0.spill_threshold\CD\FF\FF\B0.user_data_limit\00\AF.xgl_cache_info\82\B3.128_bit_cache_hash\92\CF\D6\9C\B4\09\0A8A\DA\CF3\09\AF\FF\11\A9U\06\AD.llpc_version\A470.1\AEamdpal.version\92\03\00"}
!14 = !{i32 0}
!15 = !{i32 1}
!16 = !{}
; CHECK-LABEL: @lgc.shader.VS.main(
; CHECK-NEXT:  .entry:
; CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.amdgcn.s.getpc()
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64 [[TMP0]] to <2 x i32>
; CHECK-NEXT:    [[I:%.*]] = call <4 x i32> @lgc.input.import.generic.v4i32(i1 false, i32 2, i32 0, i32 0, i32 poison)
; CHECK-NEXT:    [[DOTFR:%.*]] = freeze <4 x i32> [[I]]
; CHECK-NEXT:    [[__LLPC_INPUT_PROXY_4_0_VEC_EXTRACT:%.*]] = extractelement <4 x i32> [[DOTFR]], i64 0
; CHECK-NEXT:    [[TMP2:%.*]] = call i32 @lgc.load.user.data.i32(i32 0)
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x i32> [[TMP1]], i32 [[TMP2]], i64 0
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast <2 x i32> [[TMP3]] to i64
; CHECK-NEXT:    [[TMP5:%.*]] = inttoptr i64 [[TMP4]] to ptr addrspace(4)
; CHECK-NEXT:    [[I1:%.*]] = getelementptr i8, ptr addrspace(4) [[TMP5]], i32 0
; CHECK-NEXT:    [[I3:%.*]] = mul i32 [[__LLPC_INPUT_PROXY_4_0_VEC_EXTRACT]], 16
; CHECK-NEXT:    [[I4:%.*]] = sext i32 [[I3]] to i64
; CHECK-NEXT:    [[I5:%.*]] = getelementptr i8, ptr addrspace(4) [[I1]], i64 [[I4]]
; CHECK-NEXT:    [[I6:%.*]] = load <4 x i32>, ptr addrspace(4) [[I5]], align 16, !invariant.load !16
; CHECK-NEXT:    [[I7:%.*]] = getelementptr i8, ptr addrspace(4) [[I1]], i64 [[I4]]
; CHECK-NEXT:    [[I8:%.*]] = load <4 x i32>, ptr addrspace(4) [[I7]], align 16, !invariant.load !16
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast <4 x i32> [[I8]] to <4 x float>
; CHECK-NEXT:    [[TMP7:%.*]] = call i32 @llvm.amdgcn.waterfall.begin.i32(i32 0, i32 [[I3]])
; CHECK-NEXT:    [[TMP8:%.*]] = call i32 @llvm.amdgcn.waterfall.readfirstlane.i32.i32(i32 [[TMP7]], i32 [[I3]])
; CHECK-NEXT:    [[TMP9:%.*]] = sext i32 [[TMP8]] to i64
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr i8, ptr addrspace(4) [[I1]], i64 [[TMP9]]
; CHECK-NEXT:    [[TMP11:%.*]] = load <4 x i32>, ptr addrspace(4) [[TMP10]], align 16, !invariant.load !16
; CHECK-NEXT:    [[TMP12:%.*]] = call <4 x i32> @llvm.amdgcn.waterfall.last.use.v4i32(i32 [[TMP7]], <4 x i32> [[TMP11]])
; CHECK-NEXT:    call void @llvm.amdgcn.struct.buffer.store.format.v4f32(<4 x float> [[TMP6]], <4 x i32> [[TMP12]], i32 1, i32 0, i32 0, i32 0)
; CHECK-NEXT:    ret void
;
