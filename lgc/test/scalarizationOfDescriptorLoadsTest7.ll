; NOTE: Assertions have been autogenerated by tool/update_llpc_test_checks.py UTC_ARGS: --tool lgc
; RUN: lgc -mcpu=gfx1010 -print-after=lgc-builder-replayer -o - %s 2>&1 | FileCheck --check-prefixes=CHECK %s

; This test checks how the scalarization of descriptor loads works if the values are defined in different basic blocks.

source_filename = "llpc_fragment_7"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-p7:160:256:256:32-p8:128:128-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7:8-p32:32:32"
target triple = "amdgcn--amdpal"

; Function Attrs: nounwind
define dllexport spir_func void @lgc.shader.FS.main() local_unnamed_addr #0 !spirv.ExecutionModel !8 !lgc.shaderstage !9 {
.entry:
  %i = call i32 (...) @lgc.create.read.generic.input.i32(i32 3, i32 0, i32 0, i32 0, i32 17, i32 poison)
  %i1 = call ptr addrspace(4) (...) @lgc.create.get.desc.ptr.p4(i32 1, i32 1, i64 0, i32 7)
  %i2 = call i32 (...) @lgc.create.get.desc.stride.i32(i32 1, i32 1, i64 0, i32 7)
  %i3 = call ptr addrspace(4) (...) @lgc.create.get.desc.ptr.p4(i32 2, i32 2, i64 0, i32 7)
  %i4 = call i32 (...) @lgc.create.get.desc.stride.i32(i32 2, i32 2, i64 0, i32 7)
  br label %bb1

bb1:                                              ; preds = %.entry
  %i5 = mul i32 %i, %i2
  %i6 = sext i32 %i5 to i64
  %i7 = getelementptr i8, ptr addrspace(4) %i1, i64 %i6
  br label %bb2

bb2:                                              ; preds = %bb1
  %i8 = mul i32 %i, %i4
  %i9 = sext i32 %i8 to i64
  %i10 = getelementptr i8, ptr addrspace(4) %i3, i64 %i9
  %i11 = load <4 x i32>, ptr addrspace(4) %i10, align 16, !invariant.load !10
  br label %bb3

bb3:                                              ; preds = %bb2
  %i12 = load <8 x i32>, ptr addrspace(4) %i7, align 32, !invariant.load !10
  %i13 = call reassoc nnan nsz arcp contract afn <4 x float> (...) @lgc.create.image.sample.v4f32(i32 1, i32 24, <8 x i32> %i12, <4 x i32> %i11, i32 1, <2 x float> zeroinitializer)
  call void (...) @lgc.create.write.generic.output(<4 x float> %i13, i32 0, i32 0, i32 0, i32 0, i32 0, i32 poison)
  ret void
}

declare spir_func void @spirv.NonUniform.i32(i32) local_unnamed_addr

; Function Attrs: nounwind memory(none)
declare !lgc.create.opcode !11 ptr addrspace(4) @lgc.create.get.desc.ptr.p4(...) local_unnamed_addr #1

; Function Attrs: nounwind memory(none)
declare !lgc.create.opcode !12 i32 @lgc.create.get.desc.stride.i32(...) local_unnamed_addr #1

declare spir_func void @"spirv.NonUniform.s[s[p4,i32,i32,i32],s[p4,i32,i32]]"({ { ptr addrspace(4), i32, i32, i32 }, { ptr addrspace(4), i32, i32 } }) local_unnamed_addr

declare spir_func void @"spirv.NonUniform.s[a3v8i32,s[v4i32,i32]]"({ [3 x <8 x i32>], { <4 x i32>, i32 } }) local_unnamed_addr

; Function Attrs: nounwind willreturn memory(read)
declare !lgc.create.opcode !13 <4 x float> @lgc.create.image.sample.v4f32(...) local_unnamed_addr #2

; Function Attrs: nounwind willreturn memory(read)
declare !lgc.create.opcode !14 i32 @lgc.create.read.generic.input.i32(...) local_unnamed_addr #2

; Function Attrs: nounwind
declare !lgc.create.opcode !15 void @lgc.create.write.generic.output(...) local_unnamed_addr #3

attributes #0 = { nounwind "denormal-fp-math-f32"="preserve-sign" }
attributes #1 = { nounwind memory(none) }
attributes #2 = { nounwind willreturn memory(read) }
attributes #3 = { nounwind }

!lgc.client = !{!0}
!lgc.unlinked = !{!1}
!lgc.options = !{!2}
!lgc.options.FS = !{!3}
!lgc.user.data.nodes = !{!4, !5}
!lgc.color.export.formats = !{!6}
!amdgpu.pal.metadata.msgpack = !{!7}

!0 = !{!"Vulkan"}
!1 = !{i32 1}
!2 = !{i32 -158725823, i32 1419665388, i32 -1015833383, i32 -491143713, i32 1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1, i32 256, i32 256, i32 2, i32 1}
!3 = !{i32 -1822594139, i32 1920663194, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 64, i32 0, i32 0, i32 3, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 20, i32 1800, i32 0, i32 0, i32 1}
!4 = !{!"DescriptorTableVaPtr", i32 7, i32 64, i32 0, i32 1, i32 1}
!5 = !{!"DescriptorCombinedTexture", i32 3, i32 64, i32 0, i32 192, i64 0, i32 7, i32 12}
!6 = !{i32 14, i32 7, i32 0, i32 0, i32 15}
!7 = !{!"\82\B0amdpal.pipelines\91\83\B0.spill_threshold\CD\FF\FF\B0.user_data_limit\00\AF.xgl_cache_info\82\B3.128_bit_cache_hash\92\CF\E8\D2\98>j\B9B\94\CF2\DEF\BF\9Fx\BC1\AD.llpc_version\A470.1\AEamdpal.version\92\03\00"}
!8 = !{i32 4}
!9 = !{i32 6}
!10 = !{}
!11 = !{i32 56}
!12 = !{i32 55}
!13 = !{i32 61}
!14 = !{i32 71}
!15 = !{i32 74}
; CHECK-LABEL: @lgc.shader.FS.main(
; CHECK-NEXT:  .entry:
; CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.amdgcn.s.getpc()
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64 [[TMP0]] to <2 x i32>
; CHECK-NEXT:    [[TMP2:%.*]] = call i64 @llvm.amdgcn.s.getpc()
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i64 [[TMP2]] to <2 x i32>
; CHECK-NEXT:    [[I:%.*]] = call i32 (...) @lgc.input.import.interpolated.i32(i1 false, i32 3, i32 0, i32 0, i32 poison, i32 1, i32 poison)
; CHECK-NEXT:    [[TMP4:%.*]] = call i32 @lgc.load.user.data.i32(i32 0)
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i32> [[TMP3]], i32 [[TMP4]], i64 0
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast <2 x i32> [[TMP5]] to i64
; CHECK-NEXT:    [[TMP7:%.*]] = inttoptr i64 [[TMP6]] to ptr addrspace(4)
; CHECK-NEXT:    [[I1:%.*]] = getelementptr i8, ptr addrspace(4) [[TMP7]], i32 0
; CHECK-NEXT:    [[TMP8:%.*]] = call i32 @lgc.load.user.data.i32(i32 0)
; CHECK-NEXT:    [[TMP9:%.*]] = insertelement <2 x i32> [[TMP1]], i32 [[TMP8]], i64 0
; CHECK-NEXT:    [[TMP10:%.*]] = bitcast <2 x i32> [[TMP9]] to i64
; CHECK-NEXT:    [[TMP11:%.*]] = inttoptr i64 [[TMP10]] to ptr addrspace(4)
; CHECK-NEXT:    [[I3:%.*]] = getelementptr i8, ptr addrspace(4) [[TMP11]], i32 32
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[I5:%.*]] = mul i32 [[I]], 48
; CHECK-NEXT:    [[I6:%.*]] = sext i32 [[I5]] to i64
; CHECK-NEXT:    [[I7:%.*]] = getelementptr i8, ptr addrspace(4) [[I1]], i64 [[I6]]
; CHECK-NEXT:    br label [[BB2:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    [[I8:%.*]] = mul i32 [[I]], 48
; CHECK-NEXT:    [[I9:%.*]] = sext i32 [[I8]] to i64
; CHECK-NEXT:    [[I10:%.*]] = getelementptr i8, ptr addrspace(4) [[I3]], i64 [[I9]]
; CHECK-NEXT:    [[I11:%.*]] = load <4 x i32>, ptr addrspace(4) [[I10]], align 16, !invariant.load !10
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb3:
; CHECK-NEXT:    [[I12:%.*]] = load <8 x i32>, ptr addrspace(4) [[I7]], align 32, !invariant.load !10
; CHECK-NEXT:    [[TMP12:%.*]] = call i32 @llvm.amdgcn.waterfall.begin.i32(i32 0, i32 [[I5]])
; CHECK-NEXT:    [[TMP13:%.*]] = call i32 @llvm.amdgcn.waterfall.readfirstlane.i32.i32(i32 [[TMP12]], i32 [[I5]])
; CHECK-NEXT:    [[TMP14:%.*]] = sext i32 [[TMP13]] to i64
; CHECK-NEXT:    [[TMP15:%.*]] = getelementptr i8, ptr addrspace(4) [[I1]], i64 [[TMP14]]
; CHECK-NEXT:    [[TMP16:%.*]] = load <8 x i32>, ptr addrspace(4) [[TMP15]], align 32, !invariant.load !10
; CHECK-NEXT:    [[TMP17:%.*]] = sext i32 [[TMP13]] to i64
; CHECK-NEXT:    [[TMP18:%.*]] = getelementptr i8, ptr addrspace(4) [[I3]], i64 [[TMP17]]
; CHECK-NEXT:    [[TMP19:%.*]] = load <4 x i32>, ptr addrspace(4) [[TMP18]], align 16, !invariant.load !10
; CHECK-NEXT:    [[TMP20:%.*]] = call reassoc nnan nsz arcp contract afn <4 x float> @llvm.amdgcn.image.sample.2d.v4f32.f32(i32 15, float 0.000000e+00, float 0.000000e+00, <8 x i32> [[TMP16]], <4 x i32> [[TMP19]], i1 false, i32 0, i32 0)
; CHECK-NEXT:    [[I13:%.*]] = call reassoc nnan nsz arcp contract afn <4 x float> @llvm.amdgcn.waterfall.end.v4f32(i32 [[TMP12]], <4 x float> [[TMP20]])
; CHECK-NEXT:    call void @lgc.output.export.generic.i32.i32.v4f32(i32 0, i32 0, <4 x float> [[I13]]) #[[ATTR5:[0-9]+]]
; CHECK-NEXT:    ret void
;
