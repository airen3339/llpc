; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --include-generated-funcs --version 3
; RUN: grep -v lgc.cps.module %s | opt --verify-each -passes="dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,remove-types-metadata" -S --lint-abort-on-error | FileCheck -check-prefix=LOWERRAYTRACINGPIPELINE %s
; RUN: opt --verify-each -passes="dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,remove-types-metadata" -S %s --lint-abort-on-error | FileCheck -check-prefix=LOWERRAYTRACINGPIPELINE-CPS %s
; RUN: opt --verify-each -passes="dxil-cont-lgc-rt-op-converter,lint,inline,lint,lower-raytracing-pipeline,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,dxil-cleanup-continuations,lint,dxil-cont-post-process,lint,remove-types-metadata" -S %s --lint-abort-on-error | FileCheck -check-prefix=POSTPROCESS-CPS %s

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-p32:32:32-i1:32-i8:8-i16:16-i32:32-i64:32-f16:16-f32:32-f64:32-v8:8-v16:16-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%dx.types.Handle = type { i8* }
%struct.DispatchSystemData = type { i32 }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.TraversalData = type { %struct.SystemData, %struct.HitData, <3 x float>, <3 x float>, float }
%struct.HitData = type { float, i32 }
%struct.AnyHitTraversalData = type { %struct.TraversalData, %struct.HitData }
%struct.TheirParams = type { i32 }
%"class.RWTexture2D<vector<float, 4> >" = type { <4 x float> }

@"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" = external constant %dx.types.Handle, align 4

declare i32 @_cont_GetContinuationStackAddr()

define i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData* %data) !pointeetys !13 {
  ret i32 5
}

; Need _cont_ReportHit to get system data type
declare  !pointeetys !22 i1 @_cont_ReportHit(%struct.AnyHitTraversalData* %data, float %t, i32 %hitKind)

declare %struct.DispatchSystemData @_AmdAwaitShader(i64, %struct.DispatchSystemData)

declare !pointeetys !15 %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.SystemData*)

declare !pointeetys !17 void @_AmdRestoreSystemData(%struct.DispatchSystemData*)

define void @_cont_ExitRayGen(ptr nocapture readonly %data) alwaysinline nounwind !pointeetys !{%struct.DispatchSystemData poison} {
  ret void
}

define void @_cont_CallShader(%struct.DispatchSystemData* %data, i32 %0) !pointeetys !18 {
  %dis_data = load %struct.DispatchSystemData, %struct.DispatchSystemData* %data, align 4
  %newdata = call %struct.DispatchSystemData @_AmdAwaitShader(i64 2, %struct.DispatchSystemData %dis_data)
  store %struct.DispatchSystemData %newdata, %struct.DispatchSystemData* %data, align 4
  call void @_AmdRestoreSystemData(%struct.DispatchSystemData* %data)
  ret void
}

define void @main() {
  %params = alloca %struct.TheirParams, align 4
  call void @dx.op.callShader.struct.TheirParams(i32 159, i32 1, %struct.TheirParams* nonnull %params)
  ret void
}

; Function Attrs: nounwind
declare !pointeetys !19 void @dx.op.callShader.struct.TheirParams(i32, i32, %struct.TheirParams*) #0

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
!6 = !{void ()* @main, !"main", null, null, !7}
!7 = !{i32 8, i32 7, i32 6, i32 16, i32 7, i32 8, i32 5, !8}
!8 = !{i32 0}
!9 = !{!10}
!10 = !{i32 0, %"class.RWTexture2D<vector<float, 4> >"* bitcast (%dx.types.Handle* @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" to %"class.RWTexture2D<vector<float, 4> >"*), !"RenderTarget", i32 0, i32 0, i32 1, i32 2, i1 false, i1 false, i1 false, !11}
!11 = !{i32 0, i32 9}
!12 = !{i32 0, i64 65536}
!13 = !{%struct.DispatchSystemData poison}
!14 = !{i32 0, %struct.DispatchSystemData poison}
!15 = !{%struct.SystemData poison}
!16 = !{i32 0, %struct.SystemData poison}
!17 = !{%struct.DispatchSystemData poison}
!18 = !{%struct.DispatchSystemData poison}
!19 = !{%struct.TheirParams poison}
!20 = !{i32 0, %struct.TheirParams poison}
!21 = !{i32 0, %struct.AnyHitTraversalData poison}
!22 = !{%struct.AnyHitTraversalData poison}
; LOWERRAYTRACINGPIPELINE-LABEL: define i32 @_cont_GetLocalRootIndex(
; LOWERRAYTRACINGPIPELINE-SAME: ptr [[DATA:%.*]]) {
; LOWERRAYTRACINGPIPELINE-NEXT:    ret i32 5
;
;
; LOWERRAYTRACINGPIPELINE-LABEL: define void @main(
; LOWERRAYTRACINGPIPELINE-SAME: i64 [[RETURNADDR:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage [[META8:![0-9]+]] !continuation.entry [[META16:![0-9]+]] !continuation.registercount [[META8]] !continuation [[META17:![0-9]+]] {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[PARAMS:%.*]] = alloca [[STRUCT_THEIRPARAMS:%.*]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [1 x i32], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 0)
; LOWERRAYTRACINGPIPELINE-NEXT:    [[DIS_DATA_I:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP2:%.*]] = getelementptr inbounds [[STRUCT_THEIRPARAMS]], ptr [[PARAMS]], i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP3:%.*]] = load i32, ptr [[TMP2]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP3]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP4:%.*]] = load [1 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP8:%.*]] = call ptr inttoptr (i64 2 to ptr)([[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA_I]], [20 x i32] poison, [1 x i32] [[TMP4]]), !continuation.registercount [[META14:![0-9]+]], !continuation.returnedRegistercount [[META14]]
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP9:%.*]] = call { [[STRUCT_DISPATCHSYSTEMDATA]], [19 x i32], [1 x i32] } @await(ptr [[TMP8]])
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP10:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [19 x i32], [1 x i32] } [[TMP9]], 2
; LOWERRAYTRACINGPIPELINE-NEXT:    store [1 x i32] [[TMP10]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_THEIRPARAMS]] poison, ptr [[PARAMS]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP6:%.*]] = getelementptr inbounds [[STRUCT_THEIRPARAMS]], ptr [[PARAMS]], i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP7:%.*]] = load i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP7]], ptr [[TMP6]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP5:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [19 x i32], [1 x i32] } [[TMP9]], 0
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP5]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 0)
; LOWERRAYTRACINGPIPELINE-NEXT:    ret void
;
;
; LOWERRAYTRACINGPIPELINE-CPS-LABEL: define i32 @_cont_GetLocalRootIndex(
; LOWERRAYTRACINGPIPELINE-CPS-SAME: ptr [[DATA:%.*]]) {
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    ret i32 5
;
;
; LOWERRAYTRACINGPIPELINE-CPS-LABEL: define void @main(
; LOWERRAYTRACINGPIPELINE-CPS-SAME: {} [[CONT_STATE:%.*]], i32 [[RETURNADDR:%.*]], i32 [[SHADER_INDEX:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage [[META8:![0-9]+]] !lgc.cps [[META14:![0-9]+]] !continuation [[META16:![0-9]+]] {
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[PARAMS:%.*]] = alloca [[STRUCT_THEIRPARAMS:%.*]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [1 x i32], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 0)
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[DIS_DATA_I:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP2:%.*]] = getelementptr inbounds [[STRUCT_THEIRPARAMS]], ptr [[PARAMS]], i32 0
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP3:%.*]] = load i32, ptr [[TMP2]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store i32 [[TMP3]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP4:%.*]] = load [1 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP5:%.*]] = call { [[STRUCT_DISPATCHSYSTEMDATA]], [19 x i32], [1 x i32] } (...) @lgc.cps.await__sl_s_struct.DispatchSystemDatasa19i32a1i32s(i32 2, i32 4, i32 5, [20 x i32] poison, [1 x i32] [[TMP4]]), !continuation.returnedRegistercount [[META14]], !continuation.registercount [[META14]]
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP6:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [19 x i32], [1 x i32] } [[TMP5]], 2
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store [1 x i32] [[TMP6]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store [[STRUCT_THEIRPARAMS]] poison, ptr [[PARAMS]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP8:%.*]] = getelementptr inbounds [[STRUCT_THEIRPARAMS]], ptr [[PARAMS]], i32 0
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP9:%.*]] = load i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store i32 [[TMP9]], ptr [[TMP8]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    [[TMP7:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [19 x i32], [1 x i32] } [[TMP5]], 0
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP7]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 0)
; LOWERRAYTRACINGPIPELINE-CPS-NEXT:    ret void
;
;
; POSTPROCESS-CPS-LABEL: define i32 @_cont_GetLocalRootIndex(
; POSTPROCESS-CPS-SAME: ptr [[DATA:%.*]]) {
; POSTPROCESS-CPS-NEXT:    ret i32 5
;
;
; POSTPROCESS-CPS-LABEL: define void @main(
; POSTPROCESS-CPS-SAME: {} [[CONT_STATE:%.*]], i32 [[CSPINIT:%.*]], i32 [[RETURNADDR:%.*]], i32 [[SHADER_INDEX:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]]) !lgc.rt.shaderstage [[META8:![0-9]+]] !lgc.cps [[META14:![0-9]+]] !continuation [[META16:![0-9]+]] {
; POSTPROCESS-CPS-NEXT:  AllocaSpillBB:
; POSTPROCESS-CPS-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; POSTPROCESS-CPS-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; POSTPROCESS-CPS-NEXT:    [[DOTFCA_0_EXTRACT3:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], 0
; POSTPROCESS-CPS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 0)
; POSTPROCESS-CPS-NEXT:    [[DIS_DATA_I_FCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT3]], 0
; POSTPROCESS-CPS-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [1 x i32] poison, i32 undef, 0
; POSTPROCESS-CPS-NEXT:    [[TMP4:%.*]] = call i64 @continuation.getAddrAndMD(ptr @main.resume.0)
; POSTPROCESS-CPS-NEXT:    [[TMP3:%.*]] = load i32, ptr [[CSP]], align 4
; POSTPROCESS-CPS-NEXT:    call void (...) @lgc.ilcps.continue(i64 2, i32 [[TMP3]], i64 [[TMP4]], i32 5, [20 x i32] poison, [1 x i32] [[DOTFCA_0_INSERT]])
; POSTPROCESS-CPS-NEXT:    unreachable
;
;
; POSTPROCESS-CPS-LABEL: define dso_local void @main.resume.0(
; POSTPROCESS-CPS-SAME: {} [[TMP0:%.*]], i32 [[CSPINIT:%.*]], i32 [[TMP1:%.*]], i32 [[TMP2:%.*]], { [[STRUCT_DISPATCHSYSTEMDATA:%.*]], [19 x i32], [1 x i32] } [[TMP3:%.*]]) !lgc.rt.shaderstage [[META8]] !lgc.cps [[META14]] !continuation [[META16]] {
; POSTPROCESS-CPS-NEXT:  entryresume.0:
; POSTPROCESS-CPS-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; POSTPROCESS-CPS-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; POSTPROCESS-CPS-NEXT:    [[TMP5:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [19 x i32], [1 x i32] } [[TMP3]], 2
; POSTPROCESS-CPS-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [1 x i32] [[TMP5]], 0
; POSTPROCESS-CPS-NEXT:    [[TMP6:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [19 x i32], [1 x i32] } [[TMP3]], 0
; POSTPROCESS-CPS-NEXT:    [[DOTFCA_0_EXTRACT4:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP6]], 0
; POSTPROCESS-CPS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 0)
; POSTPROCESS-CPS-NEXT:    ret void
;
