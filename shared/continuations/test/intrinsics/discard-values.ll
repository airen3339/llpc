; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt --verify-each -passes='dxil-cont-intrinsic-prepare,lint' -S %s 2>%t.stderr | FileCheck %s
; RUN: count 0 < %t.stderr

%struct.AnyHitData = type { float, i32 }
%struct.DispatchSystemData = type { i32 }

declare float @_AmdGetUninitializedF32()
declare i32 @_AmdGetUninitializedI32()
declare %struct.AnyHitData @_AmdGetUninitializedStruct()

declare %struct.DispatchSystemData @_cont_SetupRayGen()

declare !types !10 i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData*)

define float @discard_f32() {
; CHECK-LABEL: define float @discard_f32() {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret float poison
;
entry:
  %result = call float @_AmdGetUninitializedF32()
  ret float %result
}

define i32 @discard_i32() {
; CHECK-LABEL: define i32 @discard_i32() {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i32 poison
;
entry:
  %result = call i32 @_AmdGetUninitializedI32()
  ret i32 %result
}

define %struct.AnyHitData @discard_struct() {
; CHECK-LABEL: define %struct.AnyHitData @discard_struct() {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret [[STRUCT_ANYHITDATA:%.*]] poison
;
entry:
  %result = call %struct.AnyHitData @_AmdGetUninitializedStruct()
  ret %struct.AnyHitData %result
}

!dx.entryPoints = !{!0}
!continuation.stackAddrspace = !{!9}

!0 = !{null, !"", null, !1, !8}
!1 = !{!2, null, null, null}
!2 = !{!3}
!3 = !{i1 ()* @discard_f32, !"discard_f32", null, null, !6}
!4 = !{i1 ()* @discard_i32, !"discard_i32", null, null, !6}
!5 = !{i1 ()* @discard_struct, !"discard_struct", null, null, !6}
!6 = !{i32 8, i32 7, i32 6, i32 16, i32 7, i32 8, i32 5, !7}
!7 = !{i32 0}
!8 = !{i32 0, i64 65536}
!9 = !{i32 21}
!10 = !{!"function", i32 poison, !11}
!11 = !{i32 0, %struct.DispatchSystemData poison}
