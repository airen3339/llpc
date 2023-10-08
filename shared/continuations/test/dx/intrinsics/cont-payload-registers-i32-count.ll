; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: grep -v continuation.minPayloadRegisterCount %s | opt --verify-each -passes='dxil-cont-intrinsic-prepare,lint,dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,inline,lint,dxil-cont-pre-coroutine,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,register-buffer,lint,save-continuation-state,lint,dxil-cont-post-process,lint,remove-types-metadata' -S 2>%t0.stderr | FileCheck -check-prefix=NOMINCOUNT %s
; RUN: count 0 < %t0.stderr
; RUN: cat                                          %s | opt --verify-each -passes='dxil-cont-intrinsic-prepare,lint,dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,inline,lint,dxil-cont-pre-coroutine,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,register-buffer,lint,save-continuation-state,lint,dxil-cont-post-process,lint,remove-types-metadata' -S 2>%t1.stderr | FileCheck -check-prefix=MINCOUNT %s
; RUN: count 0 < %t1.stderr

%struct.DispatchSystemData = type { i32 }

@debug_global = external global i32

declare i32 @_AmdContPayloadRegistersI32Count()

declare %struct.DispatchSystemData @_cont_SetupRayGen()

declare !types !9 i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData*)

define void @main() {
; NOMINCOUNT-LABEL: define void @main() !continuation !9 !continuation.entry !10 !continuation.registercount !5 !continuation.state !5 {
; NOMINCOUNT-NEXT:  entry:
; NOMINCOUNT-NEXT:    [[SYSTEM_DATA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA:%.*]], align 8
; NOMINCOUNT-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; NOMINCOUNT-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; NOMINCOUNT-NEXT:    [[TMP0:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @_cont_SetupRayGen()
; NOMINCOUNT-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA]], align 4
; NOMINCOUNT-NEXT:    [[TMP1:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA]], align 4
; NOMINCOUNT-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; NOMINCOUNT-NEXT:    [[DOTFCA_0_GEP:%.*]] = getelementptr inbounds [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; NOMINCOUNT-NEXT:    store i32 [[DOTFCA_0_EXTRACT]], ptr [[DOTFCA_0_GEP]], align 4
; NOMINCOUNT-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[SYSTEM_DATA_ALLOCA]])
; NOMINCOUNT-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; NOMINCOUNT-NEXT:    store i32 15, ptr @debug_global, align 4
; NOMINCOUNT-NEXT:    call void @continuation.complete()
; NOMINCOUNT-NEXT:    unreachable
;
; MINCOUNT-LABEL: define void @main() !continuation !10 !continuation.entry !11 !continuation.registercount !5 !continuation.state !5 {
; MINCOUNT-NEXT:  entry:
; MINCOUNT-NEXT:    [[SYSTEM_DATA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA:%.*]], align 8
; MINCOUNT-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; MINCOUNT-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; MINCOUNT-NEXT:    [[TMP0:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @_cont_SetupRayGen()
; MINCOUNT-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA]], align 4
; MINCOUNT-NEXT:    [[TMP1:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA]], align 4
; MINCOUNT-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; MINCOUNT-NEXT:    [[DOTFCA_0_GEP:%.*]] = getelementptr inbounds [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; MINCOUNT-NEXT:    store i32 [[DOTFCA_0_EXTRACT]], ptr [[DOTFCA_0_GEP]], align 4
; MINCOUNT-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[SYSTEM_DATA_ALLOCA]])
; MINCOUNT-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; MINCOUNT-NEXT:    store i32 11, ptr @debug_global, align 4
; MINCOUNT-NEXT:    call void @continuation.complete()
; MINCOUNT-NEXT:    unreachable
;
entry:
  %val = call i32 @_AmdContPayloadRegistersI32Count()
  store i32 %val, i32* @debug_global, align 4
  ret void
}

!dx.entryPoints = !{!0, !3}
!continuation.maxPayloadRegisterCount = !{!7}
!continuation.minPayloadRegisterCount = !{!8}

!0 = !{null, !"", null, !1, !6}
!1 = !{!2, null, null, null}
!2 = !{!3}
!3 = !{void ()* @main, !"main", null, null, !4}
!4 = !{i32 8, i32 7, i32 6, i32 16, i32 7, i32 8, i32 5, !5}
!5 = !{i32 0}
!6 = !{i32 0, i64 65536}
!7 = !{i32 15}
!8 = !{i32 11}
!9 = !{!"function", i32 poison, !10}
!10 = !{i32 0, %struct.DispatchSystemData poison}
