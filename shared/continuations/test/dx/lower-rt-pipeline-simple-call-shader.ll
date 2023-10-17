; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --include-generated-funcs --version 3
; RUN: grep -v lgc.cps.module %s | opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,remove-types-metadata' -S 2>%t0.stderr | FileCheck -check-prefix=LOWERRAYTRACINGPIPELINE %s
; RUN: count 0 < %t0.stderr
; RUN: grep -v lgc.cps.module %s | opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,inline,lint,pre-coroutine-lowering,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,remove-types-metadata' \
; RUN:     -S 2>%t1.stderr | FileCheck -check-prefix=CLEANUP %s
; RUN: count 0 < %t1.stderr
; RUN: grep -v lgc.cps.module %s | opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,inline,lint,pre-coroutine-lowering,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,register-buffer,lint,save-continuation-state,lint,remove-types-metadata' \
; RUN:     -S 2>%t2.stderr | FileCheck -check-prefix=SAVESTATE %s
; RUN: count 0 < %t2.stderr
; RUN: opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,remove-types-metadata' -S %s 2>%t3.stderr | FileCheck -check-prefix=LOWERRAYTRACINGPIPELINE-CPS %s
; RUN: count 0 < %t3.stderr

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%dx.types.Handle = type { i8* }
%struct.DispatchSystemData = type { i32 }
%struct.TraversalData = type { %struct.SystemData }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }
%struct.MyParams = type { i32 }
%"class.RWTexture2D<vector<float, 4> >" = type { <4 x float> }

@"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" = external constant %dx.types.Handle, align 4

declare i32 @_cont_GetContinuationStackAddr()

declare %struct.DispatchSystemData @_cont_SetupRayGen()

declare %struct.DispatchSystemData @_AmdAwaitTraversal(i64, %struct.TraversalData)

declare %struct.DispatchSystemData @_AmdAwaitShader(i64, %struct.DispatchSystemData)

declare !types !13 %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.SystemData*)

declare !types !15 void @_AmdRestoreSystemData(%struct.DispatchSystemData*)

define i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData* %data) !types !17 {
  ret i32 5
}

define void @_cont_CallShader(%struct.DispatchSystemData* %data, i32 %0) !types !18 {
  %dis_data = load %struct.DispatchSystemData, %struct.DispatchSystemData* %data, align 4
  %newdata = call %struct.DispatchSystemData @_AmdAwaitShader(i64 2, %struct.DispatchSystemData %dis_data)
  store %struct.DispatchSystemData %newdata, %struct.DispatchSystemData* %data, align 4
  call void @_AmdRestoreSystemData(%struct.DispatchSystemData* %data)
  ret void
}

define void @called(%struct.MyParams* %params) !types !19 {
  call void @dx.op.callShader.struct.MyParams(i32 159, i32 2, %struct.MyParams* nonnull %params)
  ret void
}

; Function Attrs: nounwind
declare !types !21 void @dx.op.callShader.struct.MyParams(i32, i32, %struct.MyParams*) #0

attributes #0 = { nounwind }

!llvm.ident = !{!0}
!dx.version = !{!1}
!dx.valver = !{!1}
!dx.shaderModel = !{!2}
!dx.entryPoints = !{!3, !6}
!lgc.cps.module = !{}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final)"}
!1 = !{i32 1, i32 6}
!2 = !{!"lib", i32 6, i32 6}
!3 = !{null, !"", null, !4, !12}
!4 = !{!5, !9, null, null}
!5 = !{!6}
!6 = !{void (%struct.MyParams*)* @called, !"called", null, null, !7}
!7 = !{i32 8, i32 12, i32 6, i32 16, i32 7, i32 8, i32 5, !8}
!8 = !{i32 0}
!9 = !{!10}
!10 = !{i32 0, %"class.RWTexture2D<vector<float, 4> >"* bitcast (%dx.types.Handle* @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" to %"class.RWTexture2D<vector<float, 4> >"*), !"RenderTarget", i32 0, i32 0, i32 1, i32 2, i1 false, i1 false, i1 false, !11}
!11 = !{i32 0, i32 9}
!12 = !{i32 0, i64 65536}
!13 = !{!"function", %struct.BuiltInTriangleIntersectionAttributes poison, !14}
!14 = !{i32 0, %struct.SystemData poison}
!15 = !{!"function", !"void", !16}
!16 = !{i32 0, %struct.DispatchSystemData poison}
!17 = !{!"function", i32 poison, !16}
!18 = !{!"function", !"void", !16, i32 poison}
!19 = !{!"function", !"void", !20}
!20 = !{i32 0, %struct.MyParams poison}
!21 = !{!"function", !"void", i32 poison, i32 poison, !20}
; LOWERRAYTRACINGPIPELINE-LABEL: define i32 @_cont_GetLocalRootIndex(
; LOWERRAYTRACINGPIPELINE-SAME: ptr [[DATA:%.*]]) {
; LOWERRAYTRACINGPIPELINE-NEXT:    ret i32 5
;
;
; LOWERRAYTRACINGPIPELINE-LABEL: define void @_cont_CallShader.struct.MyParams(
; LOWERRAYTRACINGPIPELINE-SAME: ptr [[DATA:%.*]], i32 [[TMP0:%.*]], ptr [[TMP1:%.*]]) {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[DIS_DATA:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS:%.*]], ptr [[TMP1]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP4:%.*]] = load i32, ptr [[TMP3]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP4]], ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP5:%.*]] = call ptr inttoptr (i64 2 to ptr)([[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA]]), !continuation.registercount !16, !continuation.returnedRegistercount !16
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP6:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @await.struct.DispatchSystemData(ptr [[TMP5]])
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_MYPARAMS]] poison, ptr [[TMP1]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP1]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP8:%.*]] = load i32, ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP8]], ptr [[TMP7]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP6]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @_AmdRestoreSystemData(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    ret void
;
;
; LOWERRAYTRACINGPIPELINE-LABEL: define void @_cont_CallShader(
; LOWERRAYTRACINGPIPELINE-SAME: ptr [[DATA:%.*]], i32 [[TMP0:%.*]]) {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[DIS_DATA:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[NEWDATA:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @_AmdAwaitShader(i64 2, [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[NEWDATA]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @_AmdRestoreSystemData(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    ret void
;
;
; LOWERRAYTRACINGPIPELINE-LABEL: define %struct.DispatchSystemData @called(
; LOWERRAYTRACINGPIPELINE-SAME: [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage !17 !continuation.registercount !16 !continuation !18 {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP2:%.*]] = alloca [[STRUCT_MYPARAMS:%.*]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP3:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP3]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[SYSTEM_DATA_ALLOCA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP2]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP5:%.*]] = load i32, ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP5]], ptr [[TMP4]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @PAYLOAD)
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @_cont_CallShader.struct.MyParams(ptr [[SYSTEM_DATA_ALLOCA]], i32 2, ptr [[TMP2]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @PAYLOAD)
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP6:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP2]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP7:%.*]] = load i32, ptr [[TMP6]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP7]], ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP8:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    ret [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP8]], !continuation.registercount !16
;
;
; CLEANUP-LABEL: define i32 @_cont_GetLocalRootIndex(
; CLEANUP-SAME: ptr [[DATA:%.*]]) {
; CLEANUP-NEXT:    ret i32 5
;
;
; CLEANUP-LABEL: define void @called(
; CLEANUP-SAME: i32 [[CSPINIT:%.*]], i64 [[RETURNADDR:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage !17 !continuation.registercount !18 !continuation !19 !continuation.state !20 !continuation.stacksize !20 {
; CLEANUP-NEXT:  AllocaSpillBB:
; CLEANUP-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; CLEANUP-NEXT:    call void @continuation.save.continuation_state()
; CLEANUP-NEXT:    [[RETURNADDR_SPILL_ADDR:%.*]] = getelementptr inbounds [[CALLED_FRAME:%.*]], ptr [[CONT_STATE]], i32 0, i32 0
; CLEANUP-NEXT:    store i64 [[RETURNADDR]], ptr [[RETURNADDR_SPILL_ADDR]], align 4
; CLEANUP-NEXT:    [[TMP1:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; CLEANUP-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; CLEANUP-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CLEANUP-NEXT:    [[TMP2:%.*]] = load i32, ptr @PAYLOAD, align 4
; CLEANUP-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @PAYLOAD)
; CLEANUP-NEXT:    [[DIS_DATA_I_FCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT]], 0
; CLEANUP-NEXT:    store i32 [[TMP2]], ptr @PAYLOAD, align 4
; CLEANUP-NEXT:    [[TMP3:%.*]] = call ptr @continuation.getContinuationStackOffset()
; CLEANUP-NEXT:    [[TMP4:%.*]] = load i32, ptr [[TMP3]], align 4
; CLEANUP-NEXT:    [[TMP5:%.*]] = add i32 [[TMP4]], 8
; CLEANUP-NEXT:    store i32 [[TMP5]], ptr [[TMP3]], align 4
; CLEANUP-NEXT:    [[TMP6:%.*]] = call ptr @continuation.getContinuationStackOffset()
; CLEANUP-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @CONTINUATION_STATE, ptr [[TMP6]])
; CLEANUP-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 0
; CLEANUP-NEXT:    [[TMP8:%.*]] = load i32, ptr [[TMP7]], align 4
; CLEANUP-NEXT:    store i32 [[TMP8]], ptr @CONTINUATION_STATE, align 4
; CLEANUP-NEXT:    [[TMP9:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 1
; CLEANUP-NEXT:    [[TMP10:%.*]] = load i32, ptr [[TMP9]], align 4
; CLEANUP-NEXT:    store i32 [[TMP10]], ptr getelementptr inbounds ([2 x i32], ptr @CONTINUATION_STATE, i32 0, i32 1), align 4
; CLEANUP-NEXT:    [[TMP11:%.*]] = call ptr @continuation.getContinuationStackOffset()
; CLEANUP-NEXT:    [[TMP12:%.*]] = load i32, ptr [[TMP11]], align 4
; CLEANUP-NEXT:    call void (i64, ...) @continuation.continue(i64 2, i32 [[TMP12]], i64 ptrtoint (ptr @called.resume.0 to i64), [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA_I_FCA_0_INSERT]]), !continuation.registercount !18, !continuation.returnedRegistercount !18
; CLEANUP-NEXT:    unreachable
;
;
; CLEANUP-LABEL: define void @called.resume.0(
; CLEANUP-SAME: i32 [[TMP0:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP1:%.*]]) !lgc.rt.shaderstage !17 !continuation.registercount !18 !continuation !19 {
; CLEANUP-NEXT:  entryresume.0:
; CLEANUP-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; CLEANUP-NEXT:    [[TMP2:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 0
; CLEANUP-NEXT:    [[TMP3:%.*]] = load i32, ptr @CONTINUATION_STATE, align 4
; CLEANUP-NEXT:    store i32 [[TMP3]], ptr [[TMP2]], align 4
; CLEANUP-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 1
; CLEANUP-NEXT:    [[TMP5:%.*]] = load i32, ptr getelementptr inbounds ([2 x i32], ptr @CONTINUATION_STATE, i32 0, i32 1), align 4
; CLEANUP-NEXT:    store i32 [[TMP5]], ptr [[TMP4]], align 4
; CLEANUP-NEXT:    [[TMP6:%.*]] = call ptr @continuation.getContinuationStackOffset()
; CLEANUP-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @CONTINUATION_STATE, ptr [[TMP6]])
; CLEANUP-NEXT:    [[TMP7:%.*]] = call ptr @continuation.getContinuationStackOffset()
; CLEANUP-NEXT:    [[TMP8:%.*]] = load i32, ptr [[TMP7]], align 4
; CLEANUP-NEXT:    [[TMP9:%.*]] = add i32 [[TMP8]], -8
; CLEANUP-NEXT:    store i32 [[TMP9]], ptr [[TMP7]], align 4
; CLEANUP-NEXT:    [[TMP10:%.*]] = load i32, ptr @PAYLOAD, align 4
; CLEANUP-NEXT:    [[DOTFCA_0_EXTRACT3:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; CLEANUP-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CLEANUP-NEXT:    [[RETURNADDR_RELOAD_ADDR:%.*]] = getelementptr inbounds [[CALLED_FRAME:%.*]], ptr [[CONT_STATE]], i32 0, i32 0
; CLEANUP-NEXT:    [[RETURNADDR_RELOAD:%.*]] = load i64, ptr [[RETURNADDR_RELOAD_ADDR]], align 4
; CLEANUP-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @PAYLOAD)
; CLEANUP-NEXT:    store i32 [[TMP10]], ptr @PAYLOAD, align 4
; CLEANUP-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT3]], 0
; CLEANUP-NEXT:    call void @continuation.restore.continuation_state()
; CLEANUP-NEXT:    [[TMP11:%.*]] = call ptr @continuation.getContinuationStackOffset()
; CLEANUP-NEXT:    [[TMP12:%.*]] = load i32, ptr [[TMP11]], align 4
; CLEANUP-NEXT:    call void (i64, ...) @continuation.continue(i64 [[RETURNADDR_RELOAD]], i32 [[TMP12]], [[STRUCT_DISPATCHSYSTEMDATA]] [[DOTFCA_0_INSERT]]), !continuation.registercount !18
; CLEANUP-NEXT:    unreachable
;
;
; SAVESTATE-LABEL: define i32 @_cont_GetLocalRootIndex(
; SAVESTATE-SAME: ptr [[DATA:%.*]]) {
; SAVESTATE-NEXT:    ret i32 5
;
;
; SAVESTATE-LABEL: define void @called(
; SAVESTATE-SAME: i32 [[CSPINIT:%.*]], i64 [[RETURNADDR:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage !15 !continuation.registercount !16 !continuation !17 !continuation.state !18 !continuation.stacksize !18 {
; SAVESTATE-NEXT:  AllocaSpillBB:
; SAVESTATE-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; SAVESTATE-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; SAVESTATE-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP1:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP2:%.*]] = add i32 [[TMP1]], 0
; SAVESTATE-NEXT:    store i32 [[TMP2]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP3:%.*]] = inttoptr i32 [[TMP1]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[RETURNADDR_SPILL_ADDR:%.*]] = getelementptr inbounds [[CALLED_FRAME:%.*]], ptr [[CONT_STATE]], i32 0, i32 0
; SAVESTATE-NEXT:    store i64 [[RETURNADDR]], ptr [[RETURNADDR_SPILL_ADDR]], align 4
; SAVESTATE-NEXT:    [[TMP4:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; SAVESTATE-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP4]], 0
; SAVESTATE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; SAVESTATE-NEXT:    [[TMP5:%.*]] = load i32, ptr addrspace(20) @PAYLOAD, align 4
; SAVESTATE-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr addrspacecast (ptr addrspace(20) @PAYLOAD to ptr))
; SAVESTATE-NEXT:    [[DIS_DATA_I_FCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT]], 0
; SAVESTATE-NEXT:    store i32 [[TMP5]], ptr addrspace(20) @PAYLOAD, align 4
; SAVESTATE-NEXT:    [[TMP6:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP7:%.*]] = add i32 [[TMP6]], 8
; SAVESTATE-NEXT:    store i32 [[TMP7]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP8:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 0
; SAVESTATE-NEXT:    [[TMP9:%.*]] = load i32, ptr [[TMP8]], align 4
; SAVESTATE-NEXT:    [[TMP10:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP11:%.*]] = inttoptr i32 [[TMP10]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[TMP12:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP11]], i64 -8
; SAVESTATE-NEXT:    [[TMP13:%.*]] = getelementptr i32, ptr addrspace(21) [[TMP12]], i32 0
; SAVESTATE-NEXT:    store i32 [[TMP9]], ptr addrspace(21) [[TMP13]], align 4
; SAVESTATE-NEXT:    [[TMP14:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 1
; SAVESTATE-NEXT:    [[TMP15:%.*]] = load i32, ptr [[TMP14]], align 4
; SAVESTATE-NEXT:    [[TMP16:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP17:%.*]] = inttoptr i32 [[TMP16]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[TMP18:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP17]], i64 -8
; SAVESTATE-NEXT:    [[TMP19:%.*]] = getelementptr i32, ptr addrspace(21) [[TMP18]], i32 0
; SAVESTATE-NEXT:    [[TMP20:%.*]] = getelementptr [2 x i32], ptr addrspace(21) [[TMP19]], i32 0, i32 1
; SAVESTATE-NEXT:    store i32 [[TMP15]], ptr addrspace(21) [[TMP20]], align 4
; SAVESTATE-NEXT:    [[TMP21:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    call void (i64, ...) @continuation.continue(i64 2, i32 [[TMP21]], i64 ptrtoint (ptr @called.resume.0 to i64), [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA_I_FCA_0_INSERT]]), !continuation.registercount !16, !continuation.returnedRegistercount !16
; SAVESTATE-NEXT:    unreachable
;
;
; SAVESTATE-LABEL: define void @called.resume.0(
; SAVESTATE-SAME: i32 [[TMP0:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP1:%.*]]) !lgc.rt.shaderstage !15 !continuation.registercount !16 !continuation !17 {
; SAVESTATE-NEXT:  entryresume.0:
; SAVESTATE-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; SAVESTATE-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; SAVESTATE-NEXT:    store i32 [[TMP0]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP2:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 0
; SAVESTATE-NEXT:    [[TMP3:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP4:%.*]] = inttoptr i32 [[TMP3]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[TMP5:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP4]], i64 -8
; SAVESTATE-NEXT:    [[TMP6:%.*]] = getelementptr i32, ptr addrspace(21) [[TMP5]], i32 0
; SAVESTATE-NEXT:    [[TMP7:%.*]] = load i32, ptr addrspace(21) [[TMP6]], align 4
; SAVESTATE-NEXT:    store i32 [[TMP7]], ptr [[TMP2]], align 4
; SAVESTATE-NEXT:    [[TMP8:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 1
; SAVESTATE-NEXT:    [[TMP9:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP10:%.*]] = inttoptr i32 [[TMP9]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[TMP11:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP10]], i64 -8
; SAVESTATE-NEXT:    [[TMP12:%.*]] = getelementptr i32, ptr addrspace(21) [[TMP11]], i32 0
; SAVESTATE-NEXT:    [[TMP13:%.*]] = getelementptr [2 x i32], ptr addrspace(21) [[TMP12]], i32 0, i32 1
; SAVESTATE-NEXT:    [[TMP14:%.*]] = load i32, ptr addrspace(21) [[TMP13]], align 4
; SAVESTATE-NEXT:    store i32 [[TMP14]], ptr [[TMP8]], align 4
; SAVESTATE-NEXT:    [[TMP15:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP16:%.*]] = add i32 [[TMP15]], -8
; SAVESTATE-NEXT:    store i32 [[TMP16]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP17:%.*]] = load i32, ptr addrspace(20) @PAYLOAD, align 4
; SAVESTATE-NEXT:    [[DOTFCA_0_EXTRACT3:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; SAVESTATE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; SAVESTATE-NEXT:    [[RETURNADDR_RELOAD_ADDR:%.*]] = getelementptr inbounds [[CALLED_FRAME:%.*]], ptr [[CONT_STATE]], i32 0, i32 0
; SAVESTATE-NEXT:    [[RETURNADDR_RELOAD:%.*]] = load i64, ptr [[RETURNADDR_RELOAD_ADDR]], align 4
; SAVESTATE-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr addrspacecast (ptr addrspace(20) @PAYLOAD to ptr))
; SAVESTATE-NEXT:    store i32 [[TMP17]], ptr addrspace(20) @PAYLOAD, align 4
; SAVESTATE-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT3]], 0
; SAVESTATE-NEXT:    [[TMP18:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP19:%.*]] = add i32 [[TMP18]], 0
; SAVESTATE-NEXT:    store i32 [[TMP19]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP20:%.*]] = inttoptr i32 [[TMP19]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[TMP21:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    call void (i64, ...) @continuation.continue(i64 [[RETURNADDR_RELOAD]], i32 [[TMP21]], [[STRUCT_DISPATCHSYSTEMDATA]] [[DOTFCA_0_INSERT]]), !continuation.registercount !16
; SAVESTATE-NEXT:    unreachable
;
;
; LOWERRAYTRACINGPIPELINE-CPS-LABEL: define i32 @_cont_GetLocalRootIndex(
; LOWERRAYTRACINGPIPELINE-CPS-SAME: ptr [[DATA:%.*]]) {
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    ret i32 5
;
;
; LOWERRAYTRACINGPIPELINE-CPS-LABEL: define void @_cont_CallShader.struct.MyParams(
; LOWERRAYTRACINGPIPELINE-CPS-SAME: ptr [[DATA:%.*]], i32 [[TMP0:%.*]], ptr [[TMP1:%.*]]) {
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[DIS_DATA:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS:%.*]], ptr [[TMP1]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP4:%.*]] = load i32, ptr [[TMP3]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store i32 [[TMP4]], ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP5:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] (...) @lgc.cps.await.s_struct.DispatchSystemDatas(i32 2, i32 2, [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store [[STRUCT_MYPARAMS]] poison, ptr [[TMP1]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP6:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP1]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP7:%.*]] = load i32, ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store i32 [[TMP7]], ptr [[TMP6]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP5]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void @_AmdRestoreSystemData(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    ret void
;
;
; LOWERRAYTRACINGPIPELINE-CPS-LABEL: define void @_cont_CallShader(
; LOWERRAYTRACINGPIPELINE-CPS-SAME: ptr [[DATA:%.*]], i32 [[TMP0:%.*]]) {
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[DIS_DATA:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[NEWDATA:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @_AmdAwaitShader(i64 2, [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[NEWDATA]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void @_AmdRestoreSystemData(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    ret void
;
;
; LOWERRAYTRACINGPIPELINE-CPS-LABEL: define void @called(
; LOWERRAYTRACINGPIPELINE-CPS-SAME: {} [[CONT_STATE:%.*]], i32 [[RETURN_ADDR:%.*]], i32 [[SHADER_INDEX:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage !16 !lgc.cps !17 !continuation !18 {
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP2:%.*]] = alloca [[STRUCT_MYPARAMS:%.*]], align 8
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP3:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP3]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[SYSTEM_DATA_ALLOCA]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void @_cont_CallShader.struct.MyParams(ptr [[SYSTEM_DATA_ALLOCA]], i32 2, ptr [[TMP2]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @PAYLOAD)
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP2]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP5:%.*]] = load i32, ptr [[TMP4]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store i32 [[TMP5]], ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP6:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void (...) @lgc.cps.jump(i32 [[RETURN_ADDR]], i32 2, {} poison, [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP6]])
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    unreachable
;
