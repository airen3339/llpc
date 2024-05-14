; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 3
; RUN: opt --verify-each -passes='dxil-cont-post-process,lint' -S %s 2> %t.stderr | FileCheck %s
; RUN: count 0 < %t.stderr

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-p32:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%struct.DispatchSystemData = type { i32 }

@debug_global = external global i1

declare void @_AmdComplete() #0
declare i32 @_cont_GetContinuationStackAddr()
declare i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData*)

; Function Attrs: nounwind
define %struct.DispatchSystemData @_cont_SetupRayGen() {
; CHECK-LABEL: define %struct.DispatchSystemData @_cont_SetupRayGen() {
; CHECK-NEXT:    [[DATA:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA:%.*]] undef, i32 0, 0
; CHECK-NEXT:    [[C:%.*]] = load i1, ptr @debug_global, align 1
; CHECK-NEXT:    br i1 [[C]], label [[COMPLETE:%.*]], label [[END:%.*]]
; CHECK:       complete:
; CHECK-NEXT:    ret [[STRUCT_DISPATCHSYSTEMDATA]] poison
; CHECK:       complete.split:
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    ret [[STRUCT_DISPATCHSYSTEMDATA]] [[DATA]]
;
  %data = insertvalue %struct.DispatchSystemData undef, i32 0, 0
  %c = load i1, ptr @debug_global, align 1
  br i1 %c, label %complete, label %end

complete:                                         ; preds = %0
  call void @_AmdComplete() #3
  br label %end

end:                                              ; preds = %complete, %0
  ret %struct.DispatchSystemData %data
}

define void @RayGen(%struct.DispatchSystemData %0) !lgc.rt.shaderstage !5 !continuation.entry !0 !continuation !3 {
; CHECK-LABEL: define void @RayGen(
; CHECK-SAME: ) !lgc.rt.shaderstage [[META3:![0-9]+]] !continuation.entry [[META4:![0-9]+]] !continuation [[META5:![0-9]+]] {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    [[TMP1:%.*]] = call i32 @_cont_GetContinuationStackAddr()
; CHECK-NEXT:    store i32 [[TMP1]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[C_I:%.*]] = load i1, ptr @debug_global, align 1
; CHECK-NEXT:    br i1 [[C_I]], label [[COMPLETE_I:%.*]], label [[_CONT_SETUPRAYGEN_EXIT:%.*]]
; CHECK:       complete.i:
; CHECK-NEXT:    ret void
; CHECK:       complete.i.split:
; CHECK-NEXT:    br label [[_CONT_SETUPRAYGEN_EXIT]]
; CHECK:       _cont_SetupRayGen.exit:
; CHECK-NEXT:    ret void
;
  ret void
}

define void @RayGen.resume.0(%struct.DispatchSystemData %0) !lgc.rt.shaderstage !5 !continuation !3 {
; CHECK-LABEL: define void @RayGen.resume.0(
; CHECK-SAME: i32 [[CSPINIT:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage [[META3]] !continuation [[META5]] {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    ret void
;
  ret void
}

!dx.entryPoints = !{!1}
!continuation.stackAddrspace = !{!4}

!0 = !{}
!1 = !{void ()* @RayGen, !"RayGen", null, null, !2}
!2 = !{i32 8, i32 7}
!3 = !{void ()* @RayGen}
!4 = !{i32 21}
!5 = !{i32 0}

attributes #0 = { nounwind }
