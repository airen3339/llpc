; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --tool cross-module-inline --version 3
; RUN: cross-module-inline %s %S/inc/link-constant-expr-global.ll --link inline_fun | FileCheck %s
;
; Access a global behind a constant expression. Check that linking creates a second global.

@glob = external global float

declare i32 @inline_fun()

define i32 @main() {
; CHECK-LABEL: define i32 @main() {
; CHECK-NEXT:    [[RESULT_I:%.*]] = load i32, ptr getelementptr inbounds ([[STRUCT_MYSTRUCT:%.*]], ptr @"glob.cloned.{{.*}}", i64 0, i32 1), align 4
; CHECK-NEXT:    ret i32 [[RESULT_I]]
;
  %result = call i32 @inline_fun()
  ret i32 %result
}
