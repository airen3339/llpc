; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --include-generated-funcs --version 3
; RUN: opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,remove-types-metadata' -S %s 2>%t0.stderr | FileCheck -check-prefix=LOWERRAYTRACINGPIPELINE %s
; RUN: count 0 < %t0.stderr
; RUN: opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,inline,lint,pre-coroutine-lowering,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,remove-types-metadata' \
; RUN:     -S %s 2>%t1.stderr | FileCheck -check-prefix=CLEANUP %s
; RUN: count 0 < %t1.stderr
; RUN: opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,inline,lint,pre-coroutine-lowering,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,register-buffer,lint,save-continuation-state,lint,remove-types-metadata' \
; RUN:     -S %s 2>%t2.stderr | FileCheck -check-prefix=SAVESTATE %s
; RUN: count 0 < %t2.stderr

; @called and @main_no_call must be marked as continuation and end with a continue call to the return address

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%dx.types.Handle = type { i8* }
%struct.DispatchSystemData = type { i32 }
%struct.TraversalData = type { %struct.SystemData }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }
%struct.TheirParams = type { [1 x i32] }
%struct.MyParams = type { [3 x i32] }
%dx.types.ResourceProperties = type { i32, i32 }
%"class.RWTexture2D<vector<float, 4> >" = type { <4 x float> }

@"\01?Scene@@3URaytracingAccelerationStructure@@A" = external constant %dx.types.Handle, align 4
@"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" = external constant %dx.types.Handle, align 4

declare i32 @_cont_GetContinuationStackAddr()

declare %struct.DispatchSystemData @_cont_SetupRayGen()

declare %struct.DispatchSystemData @_AmdAwaitTraversal(i64, %struct.TraversalData)

declare %struct.DispatchSystemData @_AmdAwaitShader(i64, %struct.DispatchSystemData)

declare !types !16 %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.SystemData*)

; Function Attrs: nounwind memory(none)
declare !types !18 void @_AmdRestoreSystemData(%struct.DispatchSystemData*) #0

define i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData* %data) !types !20 {
  ret i32 5
}

define void @_cont_TraceRay(%struct.DispatchSystemData* %data, i64 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, float %6, float %7, float %8, float %9, float %10, float %11, float %12, float %13) !types !21 {
  %dis_data = load %struct.DispatchSystemData, %struct.DispatchSystemData* %data, align 4
  %sys_data = insertvalue %struct.SystemData undef, %struct.DispatchSystemData %dis_data, 0
  %trav_data = insertvalue %struct.TraversalData undef, %struct.SystemData %sys_data, 0
  %newdata = call %struct.DispatchSystemData @_AmdAwaitTraversal(i64 4, %struct.TraversalData %trav_data)
  store %struct.DispatchSystemData %newdata, %struct.DispatchSystemData* %data, align 4
  call void @_AmdRestoreSystemData(%struct.DispatchSystemData* %data)
  ret void
}

define void @_cont_CallShader(%struct.DispatchSystemData* %data, i32 %0) !types !22 {
  %dis_data = load %struct.DispatchSystemData, %struct.DispatchSystemData* %data, align 4
  %newdata = call %struct.DispatchSystemData @_AmdAwaitShader(i64 2, %struct.DispatchSystemData %dis_data)
  store %struct.DispatchSystemData %newdata, %struct.DispatchSystemData* %data, align 4
  call void @_AmdRestoreSystemData(%struct.DispatchSystemData* %data)
  ret void
}

define void @main() {
  %params = alloca %struct.TheirParams, align 4
  store %struct.TheirParams zeroinitializer, %struct.TheirParams* %params, align 4
  call void @dx.op.callShader.struct.TheirParams(i32 159, i32 1, %struct.TheirParams* nonnull %params)
  ret void
}

define void @main_no_call() {
  ret void
}

define void @called(%struct.MyParams* %arg) !types !23 {
  ret void
}

; Function Attrs: nounwind memory(none)
declare %dx.types.Handle @dx.op.annotateHandle(i32, %dx.types.Handle, %dx.types.ResourceProperties) #0

; Function Attrs: nounwind memory(read)
declare %dx.types.Handle @dx.op.createHandleForLib.dx.types.Handle(i32, %dx.types.Handle) #1

; Function Attrs: nounwind
declare !types !25 void @dx.op.callShader.struct.TheirParams(i32, i32, %struct.TheirParams*) #2

attributes #0 = { nounwind memory(none) }
attributes #1 = { nounwind memory(read) }
attributes #2 = { nounwind }

!llvm.ident = !{!0}
!dx.version = !{!1}
!dx.valver = !{!1}
!dx.shaderModel = !{!2}
!dx.entryPoints = !{!3, !6, !13, !14}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final)"}
!1 = !{i32 1, i32 6}
!2 = !{!"lib", i32 6, i32 6}
!3 = !{null, !"", null, !4, !12}
!4 = !{!5, !9, null, null}
!5 = !{!6}
!6 = !{void ()* @main, !"main", null, null, !7}
!7 = !{i32 8, i32 7, i32 6, i32 16, i32 7, i32 8, i32 5, !8}
!8 = !{i32 0}
!9 = !{!10}
!10 = !{i32 0, %"class.RWTexture2D<vector<float, 4> >"* bitcast (%dx.types.Handle* @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" to %"class.RWTexture2D<vector<float, 4> >"*), !"RenderTarget", i32 0, i32 0, i32 1, i32 2, i1 false, i1 false, i1 false, !11}
!11 = !{i32 0, i32 9}
!12 = !{i32 0, i64 65536}
!13 = !{void ()* @main_no_call, !"main_no_call", null, null, !7}
!14 = !{void (%struct.MyParams*)* @called, !"called", null, null, !15}
!15 = !{i32 8, i32 12}
!16 = !{!"function", %struct.BuiltInTriangleIntersectionAttributes poison, !17}
!17 = !{i32 0, %struct.SystemData poison}
!18 = !{!"function", !"void", !19}
!19 = !{i32 0, %struct.DispatchSystemData poison}
!20 = !{!"function", i32 poison, !19}
!21 = !{!"function", !"void", !19, i64 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, float poison, float poison, float poison, float poison, float poison, float poison, float poison, float poison}
!22 = !{!"function", !"void", !19, i32 poison}
!23 = !{!"function", !"void", !24}
!24 = !{i32 0, %struct.MyParams poison}
!25 = !{!"function", !"void", i32 poison, i32 poison, !26}
!26 = !{i32 0, %struct.TheirParams poison}
; LOWERRAYTRACINGPIPELINE-LABEL: define i32 @_cont_GetLocalRootIndex(
; LOWERRAYTRACINGPIPELINE-SAME: ptr [[DATA:%.*]]) {
; LOWERRAYTRACINGPIPELINE-NEXT:    ret i32 5
;
;
; LOWERRAYTRACINGPIPELINE-LABEL: define void @_cont_TraceRay(
; LOWERRAYTRACINGPIPELINE-SAME: ptr [[DATA:%.*]], i64 [[TMP0:%.*]], i32 [[TMP1:%.*]], i32 [[TMP2:%.*]], i32 [[TMP3:%.*]], i32 [[TMP4:%.*]], i32 [[TMP5:%.*]], float [[TMP6:%.*]], float [[TMP7:%.*]], float [[TMP8:%.*]], float [[TMP9:%.*]], float [[TMP10:%.*]], float [[TMP11:%.*]], float [[TMP12:%.*]], float [[TMP13:%.*]]) {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[DIS_DATA:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[SYS_DATA:%.*]] = insertvalue [[STRUCT_SYSTEMDATA:%.*]] undef, [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA]], 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TRAV_DATA:%.*]] = insertvalue [[STRUCT_TRAVERSALDATA:%.*]] undef, [[STRUCT_SYSTEMDATA]] [[SYS_DATA]], 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[NEWDATA:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @_AmdAwaitTraversal(i64 4, [[STRUCT_TRAVERSALDATA]] [[TRAV_DATA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[NEWDATA]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @_AmdRestoreSystemData(ptr [[DATA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    ret void
;
;
; LOWERRAYTRACINGPIPELINE-LABEL: define void @_cont_CallShader.struct.TheirParams(
; LOWERRAYTRACINGPIPELINE-SAME: ptr [[DATA:%.*]], i32 [[TMP0:%.*]], ptr [[TMP1:%.*]]) {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[DIS_DATA:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[DATA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[STRUCT_THEIRPARAMS:%.*]], ptr [[TMP1]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP4:%.*]] = load [1 x i32], ptr [[TMP3]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store [1 x i32] [[TMP4]], ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP5:%.*]] = call ptr inttoptr (i64 2 to ptr)([[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA]]), !continuation.registercount !19, !continuation.returnedRegistercount !19
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP6:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @await.struct.DispatchSystemData(ptr [[TMP5]])
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_THEIRPARAMS]] poison, ptr [[TMP1]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [[STRUCT_THEIRPARAMS]], ptr [[TMP1]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP8:%.*]] = load [1 x i32], ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store [1 x i32] [[TMP8]], ptr [[TMP7]], align 4
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
; LOWERRAYTRACINGPIPELINE-LABEL: define void @main() !lgc.rt.shaderstage !9 !continuation.entry !20 !continuation.registercount !9 !continuation !21 {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[PARAMS:%.*]] = alloca [[STRUCT_THEIRPARAMS:%.*]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA:%.*]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP1:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[SYSTEM_DATA_ALLOCA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_THEIRPARAMS]] zeroinitializer, ptr [[PARAMS]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @_cont_CallShader.struct.TheirParams(ptr [[SYSTEM_DATA_ALLOCA]], i32 1, ptr [[PARAMS]])
; LOWERRAYTRACINGPIPELINE-NEXT:    ret void
;
;
; LOWERRAYTRACINGPIPELINE-LABEL: define void @main_no_call() !lgc.rt.shaderstage !9 !continuation.entry !20 !continuation.registercount !9 !continuation !22 {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA:%.*]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP1:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[SYSTEM_DATA_ALLOCA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-NEXT:    ret void
;
;
; LOWERRAYTRACINGPIPELINE-LABEL: define %struct.DispatchSystemData @called(
; LOWERRAYTRACINGPIPELINE-SAME: [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage !23 !continuation.registercount !24 !continuation !25 {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP2:%.*]] = alloca [[STRUCT_MYPARAMS:%.*]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP3:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP3]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[SYSTEM_DATA_ALLOCA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP2]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP5:%.*]] = getelementptr i32, ptr [[TMP4]], i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP6:%.*]] = getelementptr i32, ptr [[TMP5]], i64 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP7:%.*]] = load i32, ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP7]], ptr [[TMP6]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP8:%.*]] = getelementptr i32, ptr [[TMP5]], i64 1
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP9:%.*]] = load i32, ptr getelementptr (i32, ptr @PAYLOAD, i64 1), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP9]], ptr [[TMP8]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP10:%.*]] = getelementptr i32, ptr [[TMP5]], i64 2
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP11:%.*]] = load i32, ptr getelementptr (i32, ptr @PAYLOAD, i64 2), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP11]], ptr [[TMP10]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @PAYLOAD)
; LOWERRAYTRACINGPIPELINE-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @PAYLOAD)
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP12:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP2]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP13:%.*]] = getelementptr i32, ptr [[TMP12]], i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP14:%.*]] = getelementptr i32, ptr [[TMP13]], i64 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP15:%.*]] = load i32, ptr [[TMP14]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP15]], ptr @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP16:%.*]] = getelementptr i32, ptr [[TMP13]], i64 1
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP17:%.*]] = load i32, ptr [[TMP16]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP17]], ptr getelementptr (i32, ptr @PAYLOAD, i64 1), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP18:%.*]] = getelementptr i32, ptr [[TMP13]], i64 2
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP19:%.*]] = load i32, ptr [[TMP18]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP19]], ptr getelementptr (i32, ptr @PAYLOAD, i64 2), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP20:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    ret [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP20]], !continuation.registercount !24
;
;
; CLEANUP-LABEL: define i32 @_cont_GetLocalRootIndex(
; CLEANUP-SAME: ptr [[DATA:%.*]]) {
; CLEANUP-NEXT:    ret i32 5
;
;
; CLEANUP-LABEL: define void @main() !lgc.rt.shaderstage !10 !continuation.entry !20 !continuation.registercount !10 !continuation !21 !continuation.state !10 {
; CLEANUP-NEXT:  AllocaSpillBB:
; CLEANUP-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; CLEANUP-NEXT:    [[TMP0:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA:%.*]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; CLEANUP-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], 0
; CLEANUP-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CLEANUP-NEXT:    [[DIS_DATA_I_FCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT]], 0
; CLEANUP-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [1 x i32] poison, i32 0, 0
; CLEANUP-NEXT:    store [1 x i32] [[DOTFCA_0_INSERT]], ptr @PAYLOAD, align 4
; CLEANUP-NEXT:    [[TMP1:%.*]] = call ptr @continuation.getContinuationStackOffset()
; CLEANUP-NEXT:    [[TMP2:%.*]] = load i32, ptr [[TMP1]], align 4
; CLEANUP-NEXT:    call void (i64, ...) @continuation.continue(i64 2, i32 [[TMP2]], i64 ptrtoint (ptr @main.resume.0 to i64), [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA_I_FCA_0_INSERT]]), !continuation.registercount !22, !continuation.returnedRegistercount !22
; CLEANUP-NEXT:    unreachable
;
;
; CLEANUP-LABEL: define void @main.resume.0(
; CLEANUP-SAME: i32 [[TMP0:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP1:%.*]]) !lgc.rt.shaderstage !10 !continuation.registercount !22 !continuation !21 {
; CLEANUP-NEXT:  entryresume.0:
; CLEANUP-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; CLEANUP-NEXT:    [[TMP2:%.*]] = load [1 x i32], ptr @PAYLOAD, align 4
; CLEANUP-NEXT:    [[DOTFCA_0_EXTRACT3:%.*]] = extractvalue [1 x i32] [[TMP2]], 0
; CLEANUP-NEXT:    [[DOTFCA_0_EXTRACT1:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; CLEANUP-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CLEANUP-NEXT:    call void @continuation.complete()
; CLEANUP-NEXT:    unreachable
;
;
; CLEANUP-LABEL: define void @main_no_call() !lgc.rt.shaderstage !10 !continuation.entry !20 !continuation.registercount !10 !continuation !23 !continuation.state !10 {
; CLEANUP-NEXT:  AllocaSpillBB:
; CLEANUP-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; CLEANUP-NEXT:    [[TMP0:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA:%.*]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; CLEANUP-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], 0
; CLEANUP-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CLEANUP-NEXT:    call void @continuation.complete()
; CLEANUP-NEXT:    unreachable
;
;
; CLEANUP-LABEL: define void @called(
; CLEANUP-SAME: i32 [[CSPINIT:%.*]], i64 [[RETURNADDR:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage !24 !continuation.registercount !25 !continuation !26 !continuation.state !10 {
; CLEANUP-NEXT:  AllocaSpillBB:
; CLEANUP-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; CLEANUP-NEXT:    [[TMP1:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; CLEANUP-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; CLEANUP-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CLEANUP-NEXT:    [[TMP2:%.*]] = load i32, ptr @PAYLOAD, align 4
; CLEANUP-NEXT:    [[TMP3:%.*]] = load i32, ptr getelementptr (i32, ptr @PAYLOAD, i64 1), align 4
; CLEANUP-NEXT:    [[TMP4:%.*]] = load i32, ptr getelementptr (i32, ptr @PAYLOAD, i64 2), align 4
; CLEANUP-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @PAYLOAD)
; CLEANUP-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr @PAYLOAD)
; CLEANUP-NEXT:    store i32 [[TMP2]], ptr @PAYLOAD, align 4
; CLEANUP-NEXT:    store i32 [[TMP3]], ptr getelementptr (i32, ptr @PAYLOAD, i64 1), align 4
; CLEANUP-NEXT:    store i32 [[TMP4]], ptr getelementptr (i32, ptr @PAYLOAD, i64 2), align 4
; CLEANUP-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT]], 0
; CLEANUP-NEXT:    [[TMP5:%.*]] = call ptr @continuation.getContinuationStackOffset()
; CLEANUP-NEXT:    [[TMP6:%.*]] = load i32, ptr [[TMP5]], align 4
; CLEANUP-NEXT:    call void (i64, ...) @continuation.continue(i64 [[RETURNADDR]], i32 [[TMP6]], [[STRUCT_DISPATCHSYSTEMDATA]] [[DOTFCA_0_INSERT]]), !continuation.registercount !25
; CLEANUP-NEXT:    unreachable
;
;
; SAVESTATE-LABEL: define i32 @_cont_GetLocalRootIndex(
; SAVESTATE-SAME: ptr [[DATA:%.*]]) {
; SAVESTATE-NEXT:    ret i32 5
;
;
; SAVESTATE-LABEL: define void @main() !lgc.rt.shaderstage !8 !continuation.entry !18 !continuation.registercount !8 !continuation !19 !continuation.state !8 {
; SAVESTATE-NEXT:  AllocaSpillBB:
; SAVESTATE-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; SAVESTATE-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; SAVESTATE-NEXT:    [[TMP0:%.*]] = call i32 @continuation.initialContinuationStackPtr()
; SAVESTATE-NEXT:    store i32 [[TMP0]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP1:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA:%.*]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; SAVESTATE-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; SAVESTATE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; SAVESTATE-NEXT:    [[DIS_DATA_I_FCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT]], 0
; SAVESTATE-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [1 x i32] poison, i32 0, 0
; SAVESTATE-NEXT:    [[DOTFCA_0_INSERT_FCA_0_EXTRACT:%.*]] = extractvalue [1 x i32] [[DOTFCA_0_INSERT]], 0
; SAVESTATE-NEXT:    store i32 [[DOTFCA_0_INSERT_FCA_0_EXTRACT]], ptr addrspace(20) @PAYLOAD, align 4
; SAVESTATE-NEXT:    [[TMP2:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    call void (i64, ...) @continuation.continue(i64 2, i32 [[TMP2]], i64 ptrtoint (ptr @main.resume.0 to i64), [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA_I_FCA_0_INSERT]]), !continuation.registercount !20, !continuation.returnedRegistercount !20
; SAVESTATE-NEXT:    unreachable
;
;
; SAVESTATE-LABEL: define void @main.resume.0(
; SAVESTATE-SAME: i32 [[TMP0:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP1:%.*]]) !lgc.rt.shaderstage !8 !continuation.registercount !20 !continuation !19 {
; SAVESTATE-NEXT:  entryresume.0:
; SAVESTATE-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; SAVESTATE-NEXT:    [[TMP2:%.*]] = load i32, ptr addrspace(20) @PAYLOAD, align 4
; SAVESTATE-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [1 x i32] poison, i32 [[TMP2]], 0
; SAVESTATE-NEXT:    [[DOTFCA_0_EXTRACT3:%.*]] = extractvalue [1 x i32] [[DOTFCA_0_INSERT]], 0
; SAVESTATE-NEXT:    [[DOTFCA_0_EXTRACT1:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; SAVESTATE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; SAVESTATE-NEXT:    call void @continuation.complete()
; SAVESTATE-NEXT:    unreachable
;
;
; SAVESTATE-LABEL: define void @main_no_call() !lgc.rt.shaderstage !8 !continuation.entry !18 !continuation.registercount !8 !continuation !21 !continuation.state !8 {
; SAVESTATE-NEXT:  AllocaSpillBB:
; SAVESTATE-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; SAVESTATE-NEXT:    [[TMP0:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA:%.*]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; SAVESTATE-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], 0
; SAVESTATE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; SAVESTATE-NEXT:    call void @continuation.complete()
; SAVESTATE-NEXT:    unreachable
;
;
; SAVESTATE-LABEL: define void @called(
; SAVESTATE-SAME: i32 [[CSPINIT:%.*]], i64 [[RETURNADDR:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage !22 !continuation.registercount !23 !continuation !24 !continuation.state !8 {
; SAVESTATE-NEXT:  AllocaSpillBB:
; SAVESTATE-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; SAVESTATE-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; SAVESTATE-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP1:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; SAVESTATE-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; SAVESTATE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; SAVESTATE-NEXT:    [[TMP2:%.*]] = load i32, ptr addrspace(20) @PAYLOAD, align 4
; SAVESTATE-NEXT:    [[TMP3:%.*]] = load i32, ptr addrspace(20) addrspacecast (ptr getelementptr (i32, ptr addrspacecast (ptr addrspace(20) @PAYLOAD to ptr), i64 1) to ptr addrspace(20)), align 4
; SAVESTATE-NEXT:    [[TMP4:%.*]] = load i32, ptr addrspace(20) addrspacecast (ptr getelementptr (i32, ptr addrspacecast (ptr addrspace(20) @PAYLOAD to ptr), i64 2) to ptr addrspace(20)), align 4
; SAVESTATE-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr addrspacecast (ptr addrspace(20) @PAYLOAD to ptr))
; SAVESTATE-NEXT:    call void (...) @registerbuffer.setpointerbarrier(ptr addrspacecast (ptr addrspace(20) @PAYLOAD to ptr))
; SAVESTATE-NEXT:    store i32 [[TMP2]], ptr addrspace(20) @PAYLOAD, align 4
; SAVESTATE-NEXT:    store i32 [[TMP3]], ptr addrspace(20) addrspacecast (ptr getelementptr (i32, ptr addrspacecast (ptr addrspace(20) @PAYLOAD to ptr), i64 1) to ptr addrspace(20)), align 4
; SAVESTATE-NEXT:    store i32 [[TMP4]], ptr addrspace(20) addrspacecast (ptr getelementptr (i32, ptr addrspacecast (ptr addrspace(20) @PAYLOAD to ptr), i64 2) to ptr addrspace(20)), align 4
; SAVESTATE-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT]], 0
; SAVESTATE-NEXT:    [[TMP5:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    call void (i64, ...) @continuation.continue(i64 [[RETURNADDR]], i32 [[TMP5]], [[STRUCT_DISPATCHSYSTEMDATA]] [[DOTFCA_0_INSERT]]), !continuation.registercount !23
; SAVESTATE-NEXT:    unreachable
;
