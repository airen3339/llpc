; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 3
; RUN: opt --verify-each -passes='dxil-cont-intrinsic-prepare,lint' -S %s 2>%t.stderr | FileCheck %s
; RUN: count 0 < %t.stderr

declare i32 @_AmdGetRtip()

%struct.DispatchSystemData = type { i32 }
declare %struct.DispatchSystemData @_cont_SetupRayGen()
declare !types !8 i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData*)

@debug_global = external global i32

define void @main() !lgc.rt.shaderstage !1 {
; CHECK-LABEL: define void @main() !lgc.rt.shaderstage !3 {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i32 2, ptr @debug_global, align 4
; CHECK-NEXT:    ret void
;
entry:
  %val = call i32 @_AmdGetRtip()
  store i32 %val, ptr @debug_global
  ret void
}

!continuation.rtip = !{!0}

!0 = !{i32 2}
!1 = !{i32 0}
!8 = !{!"function", i32 poison, !9}
!9 = !{i32 0, %struct.DispatchSystemData poison}
