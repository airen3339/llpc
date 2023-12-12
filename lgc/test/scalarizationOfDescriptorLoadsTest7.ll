; NOTE: Assertions have been autogenerated by tool/update_llpc_test_checks.py UTC_ARGS: --tool lgc
; RUN: lgc -mcpu=gfx1010 -print-after=lgc-builder-replayer -o - %s 2>&1 | FileCheck --check-prefixes=CHECK %s
; ModuleID = 'lgcPipeline'
source_filename = "llpc_fragment_7"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-p7:160:256:256:32-p8:128:128-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7:8-p32:32:32"
target triple = "amdgcn--amdpal"

; Function Attrs: nounwind
define dllexport spir_func void @lgc.shader.FS.main() local_unnamed_addr #0 !spirv.ExecutionModel !8 !lgc.shaderstage !9 {
.entry:
  %0 = call i32 (...) @lgc.create.read.generic.input.i32(i32 3, i32 0, i32 0, i32 0, i32 17, i32 poison)
  %1 = call ptr addrspace(4) (...) @lgc.create.get.desc.ptr.p4(i32 1, i32 1, i64 0, i32 7)
  %2 = call i32 (...) @lgc.create.get.desc.stride.i32(i32 1, i32 1, i64 0, i32 7)
  %3 = call ptr addrspace(4) (...) @lgc.create.get.desc.ptr.p4(i32 2, i32 2, i64 0, i32 7)
  %4 = call i32 (...) @lgc.create.get.desc.stride.i32(i32 2, i32 2, i64 0, i32 7)
  br label %bb1

bb1:
  %5 = mul i32 %0, %2
  %6 = sext i32 %5 to i64
  %7 = getelementptr i8, ptr addrspace(4) %1, i64 %6
  br label %bb2

bb2:
  %8 = mul i32 %0, %4
  %9 = sext i32 %8 to i64
  %10 = getelementptr i8, ptr addrspace(4) %3, i64 %9
  %11 = load <4 x i32>, ptr addrspace(4) %10, align 16, !invariant.load !10
  br label %bb3

bb3:
  %12 = load <8 x i32>, ptr addrspace(4) %7, align 32, !invariant.load !10
  %13 = call reassoc nnan nsz arcp contract afn <4 x float> (...) @lgc.create.image.sample.v4f32(i32 1, i32 24, <8 x i32> %12, <4 x i32> %11, i32 1, <2 x float> zeroinitializer)
  call void (...) @lgc.create.write.generic.output(<4 x float> %13, i32 0, i32 0, i32 0, i32 0, i32 0, i32 poison)
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
; CHECK-NEXT:    [[TMP4:%.*]] = call i32 (...) @lgc.input.import.interpolated.i32(i1 false, i32 3, i32 0, i32 0, i32 poison, i32 1, i32 poison)
; CHECK-NEXT:    [[TMP5:%.*]] = call i32 @lgc.load.user.data.i32(i32 0)
; CHECK-NEXT:    [[TMP6:%.*]] = insertelement <2 x i32> [[TMP3]], i32 [[TMP5]], i64 0
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast <2 x i32> [[TMP6]] to i64
; CHECK-NEXT:    [[TMP8:%.*]] = inttoptr i64 [[TMP7]] to ptr addrspace(4)
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr i8, ptr addrspace(4) [[TMP8]], i32 0
; CHECK-NEXT:    [[TMP10:%.*]] = call i32 @lgc.load.user.data.i32(i32 0)
; CHECK-NEXT:    [[TMP11:%.*]] = insertelement <2 x i32> [[TMP1]], i32 [[TMP10]], i64 0
; CHECK-NEXT:    [[TMP12:%.*]] = bitcast <2 x i32> [[TMP11]] to i64
; CHECK-NEXT:    [[TMP13:%.*]] = inttoptr i64 [[TMP12]] to ptr addrspace(4)
; CHECK-NEXT:    [[TMP14:%.*]] = getelementptr i8, ptr addrspace(4) [[TMP13]], i32 32
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[TMP15:%.*]] = mul i32 [[TMP4]], 48
; CHECK-NEXT:    [[TMP16:%.*]] = sext i32 [[TMP15]] to i64
; CHECK-NEXT:    [[TMP17:%.*]] = getelementptr i8, ptr addrspace(4) [[TMP9]], i64 [[TMP16]]
; CHECK-NEXT:    br label [[BB2:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    [[TMP18:%.*]] = mul i32 [[TMP4]], 48
; CHECK-NEXT:    [[TMP19:%.*]] = sext i32 [[TMP18]] to i64
; CHECK-NEXT:    [[TMP20:%.*]] = getelementptr i8, ptr addrspace(4) [[TMP14]], i64 [[TMP19]]
; CHECK-NEXT:    [[TMP21:%.*]] = load <4 x i32>, ptr addrspace(4) [[TMP20]], align 16, !invariant.load !10
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb3:
; CHECK-NEXT:    [[TMP22:%.*]] = load <8 x i32>, ptr addrspace(4) [[TMP17]], align 32, !invariant.load !10
; CHECK-NEXT:    [[TMP23:%.*]] = call i32 @llvm.amdgcn.waterfall.begin.i32(i32 0, i32 [[TMP15]])
; CHECK-NEXT:    [[TMP24:%.*]] = call i32 @llvm.amdgcn.waterfall.readfirstlane.i32.i32(i32 [[TMP23]], i32 [[TMP15]])
; CHECK-NEXT:    [[TMP25:%.*]] = sext i32 [[TMP24]] to i64
; CHECK-NEXT:    [[TMP26:%.*]] = getelementptr i8, ptr addrspace(4) [[TMP9]], i64 [[TMP25]]
; CHECK-NEXT:    [[TMP27:%.*]] = load <8 x i32>, ptr addrspace(4) [[TMP26]], align 32, !invariant.load !10
; CHECK-NEXT:    [[TMP28:%.*]] = sext i32 [[TMP24]] to i64
; CHECK-NEXT:    [[TMP29:%.*]] = getelementptr i8, ptr addrspace(4) [[TMP14]], i64 [[TMP28]]
; CHECK-NEXT:    [[TMP30:%.*]] = load <4 x i32>, ptr addrspace(4) [[TMP29]], align 16, !invariant.load !10
; CHECK-NEXT:    [[TMP31:%.*]] = call reassoc nnan nsz arcp contract afn <4 x float> @llvm.amdgcn.image.sample.2d.v4f32.f32(i32 15, float 0.000000e+00, float 0.000000e+00, <8 x i32> [[TMP27]], <4 x i32> [[TMP30]], i1 false, i32 0, i32 0)
; CHECK-NEXT:    [[TMP32:%.*]] = call reassoc nnan nsz arcp contract afn <4 x float> @llvm.amdgcn.waterfall.end.v4f32(i32 [[TMP23]], <4 x float> [[TMP31]])
; CHECK-NEXT:    call void @lgc.output.export.generic.i32.i32.v4f32(i32 0, i32 0, <4 x float> [[TMP32]]) #[[ATTR5:[0-9]+]]
; CHECK-NEXT:    ret void
;
