; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --include-generated-funcs --version 3
; RUN: opt --verify-each -S -o - -passes='lower-await,coro-early,lgc-coro-split,coro-cleanup,cleanup-continuations' %s | FileCheck --check-prefixes=CHECK %s
; RUN: opt --verify-each -S -o - -passes='lower-await' %s | FileCheck --check-prefixes=LOWER-AWAIT %s

; This is example output for running continufy on the -in file.
; Details of the output are likely to differ from the final production pass,
; especially instruction order and value names.

define spir_func void @raygen({} %state, i32 %rcr) !lgc.shaderstage !{i32 7} !lgc.cps !{i32 0} {
  %pushconst = call ptr addrspace(4) @lgc.user.data(i32 0)
  %fn = load ptr, ptr addrspace(4) %pushconst
  %p8 = getelementptr i8, ptr addrspace(4) %pushconst, i32 8
  %x = load i32, ptr addrspace(4) %p8
  %p16 = getelementptr i8, ptr addrspace(4) %pushconst, i32 16
  %dst = load ptr addrspace(1), ptr addrspace(4) %p16

  %cr.0 = ptrtoint ptr %fn to i32
  %cr.1 = or i32 %cr.0, 2
  %r = call [2 x i32] (...) @lgc.cps.await.a2i32(i32 %cr.1, i32 4, i32 %x, ptr addrspace(1) %dst)

  store [2 x i32] %r, ptr addrspace(1) %dst

  ; Note: RGS returns, meaning end of thread.
  ret void
}

define spir_func void @chs({} %state, i32 %rcr, i32 %x) !lgc.shaderstage !{i32 7} !lgc.cps !{i32 1} {
  %pushconst = call ptr addrspace(4) @lgc.user.data(i32 24)
  %fn = load ptr, ptr addrspace(4) %pushconst

  %cr.0 = ptrtoint ptr %fn to i32
  %cr.1 = or i32 %cr.0, 1
  %y = call i32 (...) @lgc.cps.await.i32(i32 %cr.1, i32 2, i32 %x)

  call void (...) @lgc.cps.jump(i32 %rcr, i32 5, i32 %y)
  unreachable
}

define dllexport void @lgc.shader.CS.main() !lgc.shaderstage !{i32 7} {
entry:
  %id = call <3 x i32> @lgc.shader.input.LocalInvocationId(i32 0)
  %id0 = extractelement <3 x i32> %id, i32 0
  %live = icmp ult i32 %id0, 29
  br i1 %live, label %main, label %exit

main:
  %pushconst = call ptr addrspace(4) @lgc.user.data(i32 32)
  %fn = load ptr, ptr addrspace(4) %pushconst

  %cr.0 = ptrtoint ptr %fn to i32
  call void (...) @lgc.cps.await.isVoid(i32 %cr.0, i32 1, i32 5)

  br label %exit

exit:
  ; Note: Entry kernel also returns
  ret void
}

declare ptr addrspace(4) @lgc.user.data(i32)
declare <3 x i32> @lgc.shader.input.LocalInvocationId(i32)
declare void @lgc.cps.await.isVoid(...)
declare i32 @lgc.cps.await.i32(...)
declare [2 x i32] @lgc.cps.await.a2i32(...)
declare void @lgc.cps.jump(...)
; CHECK-LABEL: define spir_func void @raygen(
; CHECK-SAME: {} [[STATE:%.*]], i32 [[RCR:%.*]]) !lgc.shaderstage !0 !lgc.cps !1 !continuation !2 {
; CHECK-NEXT:  AllocaSpillBB:
; CHECK-NEXT:    [[PUSHCONST:%.*]] = call ptr addrspace(4) @lgc.user.data(i32 0)
; CHECK-NEXT:    [[FN:%.*]] = load ptr, ptr addrspace(4) [[PUSHCONST]], align 8
; CHECK-NEXT:    [[P8:%.*]] = getelementptr i8, ptr addrspace(4) [[PUSHCONST]], i32 8
; CHECK-NEXT:    [[X:%.*]] = load i32, ptr addrspace(4) [[P8]], align 4
; CHECK-NEXT:    [[P16:%.*]] = getelementptr i8, ptr addrspace(4) [[PUSHCONST]], i32 16
; CHECK-NEXT:    [[DST:%.*]] = load ptr addrspace(1), ptr addrspace(4) [[P16]], align 8
; CHECK-NEXT:    [[CR_0:%.*]] = ptrtoint ptr [[FN]] to i32
; CHECK-NEXT:    [[CR_1:%.*]] = or i32 [[CR_0]], 2
; CHECK-NEXT:    [[TMP0:%.*]] = inttoptr i32 [[CR_1]] to ptr
; CHECK-NEXT:    [[TMP1:%.*]] = call i32 (...) @lgc.cps.as.continuation.reference(ptr @raygen.resume.0)
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[CR_1]], i32 4, {} poison, i32 [[TMP1]], i32 [[X]], ptr addrspace(1) [[DST]])
; CHECK-NEXT:    unreachable
;
;
; CHECK-LABEL: define void @raygen.resume.0(
; CHECK-SAME: {} [[TMP0:%.*]], i32 [[TMP1:%.*]], [2 x i32] [[TMP2:%.*]]) !lgc.shaderstage !0 !lgc.cps !1 !continuation !2 {
; CHECK-NEXT:  entryresume.0:
; CHECK-NEXT:    [[PUSHCONST3:%.*]] = call ptr addrspace(4) @lgc.user.data(i32 0)
; CHECK-NEXT:    [[P162:%.*]] = getelementptr i8, ptr addrspace(4) [[PUSHCONST3]], i32 16
; CHECK-NEXT:    [[DST1:%.*]] = load ptr addrspace(1), ptr addrspace(4) [[P162]], align 8
; CHECK-NEXT:    store [2 x i32] [[TMP2]], ptr addrspace(1) [[DST1]], align 4
; CHECK-NEXT:    ret void
;
;
; CHECK-LABEL: define spir_func void @chs(
; CHECK-SAME: {} [[STATE:%.*]], i32 [[RCR:%.*]], i32 [[X:%.*]]) !lgc.shaderstage !0 !lgc.cps !3 !continuation !4 {
; CHECK-NEXT:  AllocaSpillBB:
; CHECK-NEXT:    [[TMP0:%.*]] = call ptr addrspace(32) @lgc.cps.alloc(i32 8)
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[CHS_FRAME:%.*]], ptr addrspace(32) [[TMP0]], i32 0, i32 0
; CHECK-NEXT:    store i32 [[RCR]], ptr addrspace(32) [[TMP1]], align 4
; CHECK-NEXT:    [[PUSHCONST:%.*]] = call ptr addrspace(4) @lgc.user.data(i32 24)
; CHECK-NEXT:    [[FN:%.*]] = load ptr, ptr addrspace(4) [[PUSHCONST]], align 8
; CHECK-NEXT:    [[CR_0:%.*]] = ptrtoint ptr [[FN]] to i32
; CHECK-NEXT:    [[CR_1:%.*]] = or i32 [[CR_0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = inttoptr i32 [[CR_1]] to ptr
; CHECK-NEXT:    [[TMP3:%.*]] = call i32 (...) @lgc.cps.as.continuation.reference(ptr @chs.resume.0)
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[CR_1]], i32 2, {} poison, i32 [[TMP3]], i32 [[X]])
; CHECK-NEXT:    unreachable
;
;
; CHECK-LABEL: define void @chs.resume.0(
; CHECK-SAME: {} [[TMP0:%.*]], i32 [[TMP1:%.*]], i32 [[TMP2:%.*]]) !lgc.shaderstage !0 !lgc.cps !3 !continuation !4 {
; CHECK-NEXT:  entryresume.0:
; CHECK-NEXT:    [[TMP3:%.*]] = call ptr addrspace(32) @lgc.cps.peek(i32 8)
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[CHS_FRAME:%.*]], ptr addrspace(32) [[TMP3]], i32 0, i32 0
; CHECK-NEXT:    [[RCR_RELOAD:%.*]] = load i32, ptr addrspace(32) [[TMP4]], align 4
; CHECK-NEXT:    call void @lgc.cps.free(i32 8)
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[RCR_RELOAD]], i32 5, i32 [[TMP2]])
; CHECK-NEXT:    unreachable
;
;
; CHECK-LABEL: define dllexport void @lgc.shader.CS.main() !lgc.shaderstage !0 !continuation !5 {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ID:%.*]] = call <3 x i32> @lgc.shader.input.LocalInvocationId(i32 0)
; CHECK-NEXT:    [[ID0:%.*]] = extractelement <3 x i32> [[ID]], i32 0
; CHECK-NEXT:    [[LIVE:%.*]] = icmp ult i32 [[ID0]], 29
; CHECK-NEXT:    br i1 [[LIVE]], label [[MAIN:%.*]], label [[EXIT:%.*]]
; CHECK:       main:
; CHECK-NEXT:    [[PUSHCONST:%.*]] = call ptr addrspace(4) @lgc.user.data(i32 32)
; CHECK-NEXT:    [[FN:%.*]] = load ptr, ptr addrspace(4) [[PUSHCONST]], align 8
; CHECK-NEXT:    [[CR_0:%.*]] = ptrtoint ptr [[FN]] to i32
; CHECK-NEXT:    [[TMP0:%.*]] = inttoptr i32 [[CR_0]] to ptr
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[CR_0]], i32 1, {} poison, i32 poison, i32 5)
; CHECK-NEXT:    unreachable
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
;
; LOWER-AWAIT-LABEL: define spir_func { ptr, ptr } @raygen(
; LOWER-AWAIT-SAME: {} [[STATE:%.*]], i32 [[RCR:%.*]], ptr [[TMP0:%.*]]) !lgc.shaderstage !0 !lgc.cps !1 !continuation !2 {
; LOWER-AWAIT-NEXT:    [[TMP2:%.*]] = call token @llvm.coro.id.retcon(i32 8, i32 4, ptr [[TMP0]], ptr @continuation.prototype.raygen, ptr @continuation.malloc, ptr @continuation.free)
; LOWER-AWAIT-NEXT:    [[TMP3:%.*]] = call ptr @llvm.coro.begin(token [[TMP2]], ptr null)
; LOWER-AWAIT-NEXT:    [[PUSHCONST:%.*]] = call ptr addrspace(4) @lgc.user.data(i32 0)
; LOWER-AWAIT-NEXT:    [[FN:%.*]] = load ptr, ptr addrspace(4) [[PUSHCONST]], align 8
; LOWER-AWAIT-NEXT:    [[P8:%.*]] = getelementptr i8, ptr addrspace(4) [[PUSHCONST]], i32 8
; LOWER-AWAIT-NEXT:    [[X:%.*]] = load i32, ptr addrspace(4) [[P8]], align 4
; LOWER-AWAIT-NEXT:    [[P16:%.*]] = getelementptr i8, ptr addrspace(4) [[PUSHCONST]], i32 16
; LOWER-AWAIT-NEXT:    [[DST:%.*]] = load ptr addrspace(1), ptr addrspace(4) [[P16]], align 8
; LOWER-AWAIT-NEXT:    [[CR_0:%.*]] = ptrtoint ptr [[FN]] to i32
; LOWER-AWAIT-NEXT:    [[CR_1:%.*]] = or i32 [[CR_0]], 2
; LOWER-AWAIT-NEXT:    [[TMP4:%.*]] = inttoptr i32 [[CR_1]] to ptr
; LOWER-AWAIT-NEXT:    [[TMP5:%.*]] = call ptr [[TMP4]](i32 [[CR_1]], i32 4, i32 [[X]], ptr addrspace(1) [[DST]])
; LOWER-AWAIT-NEXT:    [[TMP6:%.*]] = call i1 (...) @llvm.coro.suspend.retcon.i1(ptr [[TMP5]])
; LOWER-AWAIT-NEXT:    [[TMP7:%.*]] = call [2 x i32] @continuations.getReturnValue.a2i32()
; LOWER-AWAIT-NEXT:    store [2 x i32] [[TMP7]], ptr addrspace(1) [[DST]], align 4
; LOWER-AWAIT-NEXT:    call void (...) @continuation.return()
; LOWER-AWAIT-NEXT:    unreachable
;
;
; LOWER-AWAIT-LABEL: define spir_func { ptr, ptr } @chs(
; LOWER-AWAIT-SAME: {} [[STATE:%.*]], i32 [[RCR:%.*]], i32 [[X:%.*]], ptr [[TMP0:%.*]]) !lgc.shaderstage !0 !lgc.cps !3 !continuation !4 {
; LOWER-AWAIT-NEXT:    [[TMP2:%.*]] = call token @llvm.coro.id.retcon(i32 8, i32 4, ptr [[TMP0]], ptr @continuation.prototype.chs, ptr @continuation.malloc, ptr @continuation.free)
; LOWER-AWAIT-NEXT:    [[TMP3:%.*]] = call ptr @llvm.coro.begin(token [[TMP2]], ptr null)
; LOWER-AWAIT-NEXT:    [[PUSHCONST:%.*]] = call ptr addrspace(4) @lgc.user.data(i32 24)
; LOWER-AWAIT-NEXT:    [[FN:%.*]] = load ptr, ptr addrspace(4) [[PUSHCONST]], align 8
; LOWER-AWAIT-NEXT:    [[CR_0:%.*]] = ptrtoint ptr [[FN]] to i32
; LOWER-AWAIT-NEXT:    [[CR_1:%.*]] = or i32 [[CR_0]], 1
; LOWER-AWAIT-NEXT:    [[TMP4:%.*]] = inttoptr i32 [[CR_1]] to ptr
; LOWER-AWAIT-NEXT:    [[TMP5:%.*]] = call ptr [[TMP4]](i32 [[CR_1]], i32 2, i32 [[X]])
; LOWER-AWAIT-NEXT:    [[TMP6:%.*]] = call i1 (...) @llvm.coro.suspend.retcon.i1(ptr [[TMP5]])
; LOWER-AWAIT-NEXT:    [[TMP7:%.*]] = call i32 @continuations.getReturnValue.i32()
; LOWER-AWAIT-NEXT:    call void (...) @lgc.cps.jump(i32 [[RCR]], i32 5, i32 [[TMP7]])
; LOWER-AWAIT-NEXT:    unreachable
;
;
; LOWER-AWAIT-LABEL: define dllexport { ptr, ptr } @lgc.shader.CS.main(
; LOWER-AWAIT-SAME: ptr [[TMP0:%.*]]) !lgc.shaderstage !0 !continuation !5 {
; LOWER-AWAIT-NEXT:  entry:
; LOWER-AWAIT-NEXT:    [[TMP1:%.*]] = call token @llvm.coro.id.retcon(i32 8, i32 4, ptr [[TMP0]], ptr @continuation.prototype.lgc.shader.CS.main, ptr @continuation.malloc, ptr @continuation.free)
; LOWER-AWAIT-NEXT:    [[TMP2:%.*]] = call ptr @llvm.coro.begin(token [[TMP1]], ptr null)
; LOWER-AWAIT-NEXT:    [[ID:%.*]] = call <3 x i32> @lgc.shader.input.LocalInvocationId(i32 0)
; LOWER-AWAIT-NEXT:    [[ID0:%.*]] = extractelement <3 x i32> [[ID]], i32 0
; LOWER-AWAIT-NEXT:    [[LIVE:%.*]] = icmp ult i32 [[ID0]], 29
; LOWER-AWAIT-NEXT:    br i1 [[LIVE]], label [[MAIN:%.*]], label [[EXIT:%.*]]
; LOWER-AWAIT:       main:
; LOWER-AWAIT-NEXT:    [[PUSHCONST:%.*]] = call ptr addrspace(4) @lgc.user.data(i32 32)
; LOWER-AWAIT-NEXT:    [[FN:%.*]] = load ptr, ptr addrspace(4) [[PUSHCONST]], align 8
; LOWER-AWAIT-NEXT:    [[CR_0:%.*]] = ptrtoint ptr [[FN]] to i32
; LOWER-AWAIT-NEXT:    [[TMP3:%.*]] = inttoptr i32 [[CR_0]] to ptr
; LOWER-AWAIT-NEXT:    [[TMP4:%.*]] = call ptr [[TMP3]](i32 [[CR_0]], i32 1, i32 5)
; LOWER-AWAIT-NEXT:    [[TMP5:%.*]] = call i1 (...) @llvm.coro.suspend.retcon.i1(ptr [[TMP4]])
; LOWER-AWAIT-NEXT:    br label [[EXIT]]
; LOWER-AWAIT:       exit:
; LOWER-AWAIT-NEXT:    call void (...) @continuation.return()
; LOWER-AWAIT-NEXT:    unreachable
;
