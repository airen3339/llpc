; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --include-generated-funcs --version 3
; RUN: opt --verify-each -passes='dxil-cont-intrinsic-prepare,lint,dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,inline,lint,dxil-cont-pre-coroutine,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,register-buffer,lint,save-continuation-state,lint,dxil-cont-post-process,lint,remove-types-metadata' \
; RUN:     -S %s 2>%t.stderr | FileCheck -check-prefix=SAVESTATE %s
; RUN: count 0 < %t.stderr

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%dx.types.Handle = type { i8* }
%struct.DispatchSystemData = type { i32 }
%struct.TraversalData = type { %struct.SystemData }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }
%struct.MyParams = type { i32 }
%dx.types.fouri32 = type { i32, i32, i32, i32 }
%dx.types.ResourceProperties = type { i32, i32 }
%"class.RWTexture2D<vector<float, 4> >" = type { <4 x float> }

@"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" = external constant %dx.types.Handle, align 4

declare i32 @_cont_GetContinuationStackAddr()

declare %struct.DispatchSystemData @_cont_SetupRayGen()

declare %struct.DispatchSystemData @_AmdAwaitTraversal(i64, %struct.TraversalData)

declare %struct.DispatchSystemData @_AmdAwaitShader(i64, %struct.DispatchSystemData)

declare !types !14 %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.SystemData*)

; Function Attrs: nounwind memory(none)
declare !types !16 <3 x i32> @_cont_DispatchRaysIndex3(%struct.DispatchSystemData* nocapture readnone) #0

; Function Attrs: nounwind memory(none)
declare !types !18 void @_AmdRestoreSystemData(%struct.DispatchSystemData*) #0

define i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData* %data) !types !19 {
  ret i32 5
}

define void @_cont_CallShader(%struct.DispatchSystemData* %data, i32 %0) !types !20 {
  %dis_data = load %struct.DispatchSystemData, %struct.DispatchSystemData* %data, align 4
  %newdata = call %struct.DispatchSystemData @_AmdAwaitShader(i64 2, %struct.DispatchSystemData %dis_data)
  store %struct.DispatchSystemData %newdata, %struct.DispatchSystemData* %data, align 4
  call void @_AmdRestoreSystemData(%struct.DispatchSystemData* %data)
  ret void
}

define void @called(%struct.MyParams* %params) !types !21 {
  %i = call i32 @dx.op.dispatchRaysIndex.i32(i32 145, i8 0)
  %unpacked = call %dx.types.fouri32 @dx.op.unpack4x8.i32(i32 219, i8 1, i32 %i)
  %params_i = getelementptr %struct.MyParams, %struct.MyParams* %params, i32 0, i32 0
  %handle0 = load %dx.types.Handle, %dx.types.Handle* @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A", align 4
  %handle1 = call %dx.types.Handle @dx.op.createHandleForLib.dx.types.Handle(i32 160, %dx.types.Handle %handle0)
  %handle2 = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle %handle1, %dx.types.ResourceProperties { i32 16, i32 0 })
  call void @dx.op.callShader.struct.MyParams(i32 159, i32 2, %struct.MyParams* nonnull %params)
  %a = extractvalue %dx.types.fouri32 %unpacked, 0
  %b = extractvalue %dx.types.fouri32 %unpacked, 1
  %c = extractvalue %dx.types.fouri32 %unpacked, 2
  %d = extractvalue %dx.types.fouri32 %unpacked, 3
  %packed = call i32 @dx.op.pack4x8.i32(i32 220, i8 0, i32 %a, i32 %b, i32 %c, i32 %d)
  call void @dx.op.textureStore.f32(i32 67, %dx.types.Handle %handle2, i32 0, i32 0, i32 undef, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 1.000000e+00, i8 15)
  store i32 %packed, i32* %params_i, align 4
  ret void
}

; Function Attrs: nounwind
declare !types !23 void @dx.op.callShader.struct.MyParams(i32, i32, %struct.MyParams*) #1

; Function Attrs: nounwind memory(none)
declare i32 @dx.op.dispatchRaysIndex.i32(i32, i8) #0

; Function Attrs: nounwind memory(none)
declare %dx.types.fouri32 @dx.op.unpack4x8.i32(i32, i8, i32) #0

; Function Attrs: nounwind memory(none)
declare i32 @dx.op.pack4x8.i32(i32, i8, i32, i32, i32, i32) #0

; Function Attrs: nounwind memory(none)
declare %dx.types.Handle @dx.op.createHandleForLib.dx.types.Handle(i32, %dx.types.Handle) #0

; Function Attrs: nounwind memory(none)
declare %dx.types.Handle @dx.op.annotateHandle(i32, %dx.types.Handle, %dx.types.ResourceProperties) #0

; Function Attrs: nounwind
declare void @dx.op.textureStore.f32(i32, %dx.types.Handle, i32, i32, i32, float, float, float, float, i8) #1

attributes #0 = { nounwind memory(none) }
attributes #1 = { nounwind }

!llvm.ident = !{!0}
!dx.version = !{!1}
!dx.valver = !{!1}
!dx.shaderModel = !{!2}
!dx.entryPoints = !{!3, !6}
!continuation.maxPayloadRegisterCount = !{!13}

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
!13 = !{i32 30}
!14 = !{!"function", %struct.BuiltInTriangleIntersectionAttributes poison, !15}
!15 = !{i32 0, %struct.SystemData poison}
!16 = !{!"function", <3 x i32> poison, !17}
!17 = !{i32 0, %struct.DispatchSystemData poison}
!18 = !{!"function", !"void", !17}
!19 = !{!"function", i32 poison, !17}
!20 = !{!"function", !"void", !17, i32 poison}
!21 = !{!"function", !"void", !22}
!22 = !{i32 0, %struct.MyParams poison}
!23 = !{!"function", !"void", i32 poison, i32 poison, !22}
; SAVESTATE-LABEL: define i32 @_cont_GetLocalRootIndex(
; SAVESTATE-SAME: ptr [[DATA:%.*]]) #[[ATTR1:[0-9]+]] {
; SAVESTATE-NEXT:    ret i32 5
;
;
; SAVESTATE-LABEL: define void @called(
; SAVESTATE-SAME: i32 [[CSPINIT:%.*]], i64 [[RETURNADDR:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !continuation !15 !continuation.registercount !16 !continuation.state !17 !continuation.stacksize !17 {
; SAVESTATE-NEXT:  AllocaSpillBB:
; SAVESTATE-NEXT:    [[SYSTEM_DATA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; SAVESTATE-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; SAVESTATE-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; SAVESTATE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA]], align 4
; SAVESTATE-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP1:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP2:%.*]] = add i32 [[TMP1]], 0
; SAVESTATE-NEXT:    store i32 [[TMP2]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP3:%.*]] = inttoptr i32 [[TMP1]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[RETURNADDR_SPILL_ADDR:%.*]] = getelementptr inbounds [[CALLED_FRAME:%.*]], ptr [[CONT_STATE]], i32 0, i32 0
; SAVESTATE-NEXT:    store i64 [[RETURNADDR]], ptr [[RETURNADDR_SPILL_ADDR]], align 4
; SAVESTATE-NEXT:    [[TMP4:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA]], align 4
; SAVESTATE-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP4]], 0
; SAVESTATE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; SAVESTATE-NEXT:    [[TMP5:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; SAVESTATE-NEXT:    [[TMP6:%.*]] = call <3 x i32> @_cont_DispatchRaysIndex3(ptr [[SYSTEM_DATA]])
; SAVESTATE-NEXT:    [[I:%.*]] = extractelement <3 x i32> [[TMP6]], i8 0
; SAVESTATE-NEXT:    [[UNPACKED:%.*]] = call [[DX_TYPES_FOURI32:%.*]] @dx.op.unpack4x8.i32(i32 219, i8 1, i32 [[I]])
; SAVESTATE-NEXT:    [[HANDLE0:%.*]] = load [[DX_TYPES_HANDLE:%.*]], ptr @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A", align 4
; SAVESTATE-NEXT:    [[HANDLE1:%.*]] = call [[DX_TYPES_HANDLE]] @dx.op.createHandleForLib.dx.types.Handle(i32 160, [[DX_TYPES_HANDLE]] [[HANDLE0]])
; SAVESTATE-NEXT:    [[HANDLE2:%.*]] = call [[DX_TYPES_HANDLE]] @dx.op.annotateHandle(i32 216, [[DX_TYPES_HANDLE]] [[HANDLE1]], [[DX_TYPES_RESOURCEPROPERTIES:%.*]] { i32 16, i32 0 })
; SAVESTATE-NEXT:    [[DIS_DATA_I_FCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT]], 0
; SAVESTATE-NEXT:    store i32 [[TMP5]], ptr addrspace(20) @REGISTERS, align 4
; SAVESTATE-NEXT:    [[TMP7:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP8:%.*]] = add i32 [[TMP7]], 8
; SAVESTATE-NEXT:    store i32 [[TMP8]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP9:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 0
; SAVESTATE-NEXT:    [[TMP10:%.*]] = load i32, ptr [[TMP9]], align 4
; SAVESTATE-NEXT:    [[TMP11:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP12:%.*]] = inttoptr i32 [[TMP11]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[TMP13:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP12]], i64 -8
; SAVESTATE-NEXT:    [[TMP14:%.*]] = getelementptr i32, ptr addrspace(21) [[TMP13]], i32 0
; SAVESTATE-NEXT:    store i32 [[TMP10]], ptr addrspace(21) [[TMP14]], align 4
; SAVESTATE-NEXT:    [[TMP15:%.*]] = getelementptr inbounds [2 x i32], ptr [[CONT_STATE]], i32 0, i32 1
; SAVESTATE-NEXT:    [[TMP16:%.*]] = load i32, ptr [[TMP15]], align 4
; SAVESTATE-NEXT:    [[TMP17:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP18:%.*]] = inttoptr i32 [[TMP17]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[TMP19:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP18]], i64 -8
; SAVESTATE-NEXT:    [[TMP20:%.*]] = getelementptr i32, ptr addrspace(21) [[TMP19]], i32 0
; SAVESTATE-NEXT:    [[TMP21:%.*]] = getelementptr [2 x i32], ptr addrspace(21) [[TMP20]], i32 0, i32 1
; SAVESTATE-NEXT:    store i32 [[TMP16]], ptr addrspace(21) [[TMP21]], align 4
; SAVESTATE-NEXT:    [[TMP22:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP23:%.*]] = call i64 @continuation.getAddrAndMD(i64 ptrtoint (ptr @called.resume.0 to i64))
; SAVESTATE-NEXT:    call void (i64, ...) @continuation.continue(i64 2, i32 [[TMP22]], i64 [[TMP23]], [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA_I_FCA_0_INSERT]]), !continuation.registercount !16, !continuation.returnedRegistercount !16
; SAVESTATE-NEXT:    unreachable
;
;
; SAVESTATE-LABEL: define void @called.resume.0(
; SAVESTATE-SAME: i32 [[TMP0:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP1:%.*]]) !continuation !15 !continuation.registercount !16 {
; SAVESTATE-NEXT:  entryresume.0:
; SAVESTATE-NEXT:    [[SYSTEM_DATA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; SAVESTATE-NEXT:    [[CONT_STATE:%.*]] = alloca [2 x i32], align 4
; SAVESTATE-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; SAVESTATE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], ptr [[SYSTEM_DATA]], align 4
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
; SAVESTATE-NEXT:    [[TMP17:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; SAVESTATE-NEXT:    [[DOTFCA_0_EXTRACT3:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; SAVESTATE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; SAVESTATE-NEXT:    [[RETURNADDR_RELOAD_ADDR:%.*]] = getelementptr inbounds [[CALLED_FRAME:%.*]], ptr [[CONT_STATE]], i32 0, i32 0
; SAVESTATE-NEXT:    [[RETURNADDR_RELOAD:%.*]] = load i64, ptr [[RETURNADDR_RELOAD_ADDR]], align 4
; SAVESTATE-NEXT:    [[HANDLE011:%.*]] = load [[DX_TYPES_HANDLE:%.*]], ptr @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A", align 4
; SAVESTATE-NEXT:    [[HANDLE110:%.*]] = call [[DX_TYPES_HANDLE]] @dx.op.createHandleForLib.dx.types.Handle(i32 160, [[DX_TYPES_HANDLE]] [[HANDLE011]])
; SAVESTATE-NEXT:    [[HANDLE29:%.*]] = call [[DX_TYPES_HANDLE]] @dx.op.annotateHandle(i32 216, [[DX_TYPES_HANDLE]] [[HANDLE110]], [[DX_TYPES_RESOURCEPROPERTIES:%.*]] { i32 16, i32 0 })
; SAVESTATE-NEXT:    [[TMP18:%.*]] = call <3 x i32> @_cont_DispatchRaysIndex3(ptr [[SYSTEM_DATA]])
; SAVESTATE-NEXT:    [[I8:%.*]] = extractelement <3 x i32> [[TMP18]], i8 0
; SAVESTATE-NEXT:    [[UNPACKED7:%.*]] = call [[DX_TYPES_FOURI32:%.*]] @dx.op.unpack4x8.i32(i32 219, i8 1, i32 [[I8]])
; SAVESTATE-NEXT:    [[TMP19:%.*]] = call <3 x i32> @_cont_DispatchRaysIndex3(ptr [[SYSTEM_DATA]])
; SAVESTATE-NEXT:    [[I6:%.*]] = extractelement <3 x i32> [[TMP19]], i8 0
; SAVESTATE-NEXT:    [[UNPACKED5:%.*]] = call [[DX_TYPES_FOURI32]] @dx.op.unpack4x8.i32(i32 219, i8 1, i32 [[I6]])
; SAVESTATE-NEXT:    [[TMP20:%.*]] = call <3 x i32> @_cont_DispatchRaysIndex3(ptr [[SYSTEM_DATA]])
; SAVESTATE-NEXT:    [[I4:%.*]] = extractelement <3 x i32> [[TMP20]], i8 0
; SAVESTATE-NEXT:    [[UNPACKED3:%.*]] = call [[DX_TYPES_FOURI32]] @dx.op.unpack4x8.i32(i32 219, i8 1, i32 [[I4]])
; SAVESTATE-NEXT:    [[TMP21:%.*]] = call <3 x i32> @_cont_DispatchRaysIndex3(ptr [[SYSTEM_DATA]])
; SAVESTATE-NEXT:    [[I2:%.*]] = extractelement <3 x i32> [[TMP21]], i8 0
; SAVESTATE-NEXT:    [[UNPACKED1:%.*]] = call [[DX_TYPES_FOURI32]] @dx.op.unpack4x8.i32(i32 219, i8 1, i32 [[I2]])
; SAVESTATE-NEXT:    [[A:%.*]] = extractvalue [[DX_TYPES_FOURI32]] [[UNPACKED7]], 0
; SAVESTATE-NEXT:    [[B:%.*]] = extractvalue [[DX_TYPES_FOURI32]] [[UNPACKED5]], 1
; SAVESTATE-NEXT:    [[C:%.*]] = extractvalue [[DX_TYPES_FOURI32]] [[UNPACKED3]], 2
; SAVESTATE-NEXT:    [[D:%.*]] = extractvalue [[DX_TYPES_FOURI32]] [[UNPACKED1]], 3
; SAVESTATE-NEXT:    [[PACKED:%.*]] = call i32 @dx.op.pack4x8.i32(i32 220, i8 0, i32 [[A]], i32 [[B]], i32 [[C]], i32 [[D]])
; SAVESTATE-NEXT:    call void @dx.op.textureStore.f32(i32 67, [[DX_TYPES_HANDLE]] [[HANDLE29]], i32 0, i32 0, i32 undef, float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 1.000000e+00, i8 15)
; SAVESTATE-NEXT:    store i32 [[PACKED]], ptr addrspace(20) @REGISTERS, align 4
; SAVESTATE-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT3]], 0
; SAVESTATE-NEXT:    [[TMP22:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP23:%.*]] = add i32 [[TMP22]], 0
; SAVESTATE-NEXT:    store i32 [[TMP23]], ptr [[CSP]], align 4
; SAVESTATE-NEXT:    [[TMP24:%.*]] = inttoptr i32 [[TMP23]] to ptr addrspace(21)
; SAVESTATE-NEXT:    [[TMP25:%.*]] = load i32, ptr [[CSP]], align 4
; SAVESTATE-NEXT:    call void (i64, ...) @continuation.continue(i64 [[RETURNADDR_RELOAD]], i32 [[TMP25]], [[STRUCT_DISPATCHSYSTEMDATA]] [[DOTFCA_0_INSERT]]), !continuation.registercount !16
; SAVESTATE-NEXT:    unreachable
;
