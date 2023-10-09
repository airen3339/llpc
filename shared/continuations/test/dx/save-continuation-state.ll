; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 3
; RUN: opt --verify-each -passes='save-continuation-state,lint' -S %s 2>%t.stderr | FileCheck %s
; RUN: count 0 < %t.stderr

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%continuation.token = type {}
%simple_await.Frame = type { i64 }

@RETURN_ADDR = external addrspace(20) global i64
@CONTINUATION_STATE = external addrspace(20) global [0 x i32]

declare %continuation.token* @async_fun()

declare void @continuation.save.continuation_state()

declare void @continuation.restore.continuation_state()

declare void @continuation.continue(i64, ...)

define void @simple_await(i32 %0, i64 %1) !continuation !1 !continuation.state !2 {
; CHECK-LABEL: define void @simple_await(
; CHECK-SAME: i32 [[TMP0:%.*]], i64 [[TMP1:%.*]]) !continuation !1 !continuation.state !2 !continuation.stacksize !3 {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[TMP0]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = add i32 [[TMP3]], 0
; CHECK-NEXT:    store i32 [[TMP4]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP5:%.*]] = inttoptr i32 [[TMP3]] to ptr addrspace(21)
; CHECK-NEXT:    [[FRAMEPTR:%.*]] = bitcast ptr addrspacecast (ptr addrspace(20) @CONTINUATION_STATE to ptr) to ptr
; CHECK-NEXT:    [[RET_ADDR:%.*]] = load i64, ptr addrspace(20) @RETURN_ADDR, align 8
; CHECK-NEXT:    [[DOTSPILL_ADDR:%.*]] = getelementptr inbounds [[SIMPLE_AWAIT_FRAME:%.*]], ptr [[FRAMEPTR]], i32 0, i32 0
; CHECK-NEXT:    store i64 [[RET_ADDR]], ptr [[DOTSPILL_ADDR]], align 8
; CHECK-NEXT:    [[RESUME_FUNC:%.*]] = bitcast ptr @simple_await.resume.0 to ptr
; CHECK-NEXT:    [[TMP6:%.*]] = insertvalue { ptr, ptr } undef, ptr [[RESUME_FUNC]], 0
; CHECK-NEXT:    [[TMP7:%.*]] = ptrtoint ptr [[RESUME_FUNC]] to i64
; CHECK-NEXT:    store i64 [[TMP7]], ptr addrspace(20) @RETURN_ADDR, align 8
; CHECK-NEXT:    call void (i64, ...) @continuation.continue(i64 ptrtoint (ptr @async_fun to i64))
; CHECK-NEXT:    unreachable
;
  call void @continuation.save.continuation_state()
  %FramePtr = bitcast i8* addrspacecast (i8 addrspace(20)* bitcast ([0 x i32] addrspace(20)* @CONTINUATION_STATE to i8 addrspace(20)*) to i8*) to %simple_await.Frame*
  %ret_addr = load i64, i64 addrspace(20)* @RETURN_ADDR, align 8
  %.spill.addr = getelementptr inbounds %simple_await.Frame, %simple_await.Frame* %FramePtr, i32 0, i32 0
  store i64 %ret_addr, i64* %.spill.addr, align 8
  %resume_func = bitcast { i8*, %continuation.token* } (i8*, i1)* bitcast (void (i32)* @simple_await.resume.0 to { i8*, %continuation.token* } (i8*, i1)*) to i8*
  %3 = insertvalue { i8*, %continuation.token* } undef, i8* %resume_func, 0
  %4 = ptrtoint i8* %resume_func to i64
  store i64 %4, i64 addrspace(20)* @RETURN_ADDR, align 8
  call void (i64, ...) @continuation.continue(i64 ptrtoint (%continuation.token* ()* @async_fun to i64))
  unreachable
}

define internal void @simple_await.resume.0(i32 %0) !continuation !1 {
; CHECK-LABEL: define internal void @simple_await.resume.0(
; CHECK-SAME: i32 [[TMP0:%.*]]) !continuation !1 {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[TMP0]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[FRAMEPTR:%.*]] = bitcast ptr addrspacecast (ptr addrspace(20) @CONTINUATION_STATE to ptr) to ptr
; CHECK-NEXT:    [[VFRAME:%.*]] = bitcast ptr [[FRAMEPTR]] to ptr
; CHECK-NEXT:    [[DOTRELOAD_ADDR:%.*]] = getelementptr inbounds [[SIMPLE_AWAIT_FRAME:%.*]], ptr [[FRAMEPTR]], i32 0, i32 0
; CHECK-NEXT:    [[DOTRELOAD:%.*]] = load i64, ptr [[DOTRELOAD_ADDR]], align 8
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = add i32 [[TMP2]], 0
; CHECK-NEXT:    store i32 [[TMP3]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = inttoptr i32 [[TMP3]] to ptr addrspace(21)
; CHECK-NEXT:    call void (i64, ...) @continuation.continue(i64 [[DOTRELOAD]])
; CHECK-NEXT:    unreachable
;
  %FramePtr = bitcast i8* addrspacecast (i8 addrspace(20)* bitcast ([0 x i32] addrspace(20)* @CONTINUATION_STATE to i8 addrspace(20)*) to i8*) to %simple_await.Frame*
  %vFrame = bitcast %simple_await.Frame* %FramePtr to i8*
  %.reload.addr = getelementptr inbounds %simple_await.Frame, %simple_await.Frame* %FramePtr, i32 0, i32 0
  %.reload = load i64, i64* %.reload.addr, align 8
  call void @continuation.restore.continuation_state()
  call void (i64, ...) @continuation.continue(i64 %.reload)
  unreachable
}

define void @odd_cont_state_size(i32 %0, i64 %1) !continuation !3 !continuation.state !4 {
; CHECK-LABEL: define void @odd_cont_state_size(
; CHECK-SAME: i32 [[TMP0:%.*]], i64 [[TMP1:%.*]]) !continuation !4 !continuation.state !5 !continuation.stacksize !3 {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[TMP0]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = add i32 [[TMP3]], 0
; CHECK-NEXT:    store i32 [[TMP4]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP5:%.*]] = inttoptr i32 [[TMP3]] to ptr addrspace(21)
; CHECK-NEXT:    call void (i64, ...) @continuation.continue(i64 2)
; CHECK-NEXT:    unreachable
;
  call void @continuation.save.continuation_state()
  call void (i64, ...) @continuation.continue(i64 2)
  unreachable
}

; Continuation state is larger than the register size
define void @large_cont_state_size(i32 %0, i64 %1) !continuation !5 !continuation.state !6 {
; CHECK-LABEL: define void @large_cont_state_size(
; CHECK-SAME: i32 [[TMP0:%.*]], i64 [[TMP1:%.*]]) !continuation !6 !continuation.state !7 !continuation.stacksize !3 {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[TMP0]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = add i32 [[TMP3]], 0
; CHECK-NEXT:    store i32 [[TMP4]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP5:%.*]] = inttoptr i32 [[TMP3]] to ptr addrspace(21)
; CHECK-NEXT:    call void (i64, ...) @continuation.continue(i64 2)
; CHECK-NEXT:    unreachable
;
  call void @continuation.save.continuation_state()
  call void (i64, ...) @continuation.continue(i64 2)
  unreachable
}

attributes #0 = { nounwind }

!continuation.stackAddrspace = !{!0}

!0 = !{i32 21}

!1 = !{void (i32, i64)* @simple_await}
!2 = !{i32 8}

!3 = !{void (i32, i64)* @odd_cont_state_size}
!4 = !{i32 2}

!5 = !{void (i32, i64)* @large_cont_state_size}
!6 = !{i32 2048}
