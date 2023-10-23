; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint' -S %s 2>%t0.stderr | FileCheck %s
; RUN: count 0 < %t0.stderr

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%struct.MyParams = type { [48 x i32] }
%struct.TheirParams = type { [64 x i32] }
%struct.TheirParams2 = type { [65 x i32] }
%struct.RayPayload = type { [68 x i32] }
%dx.types.Handle = type { i8* }
%dx.types.ResourceProperties = type { i32, i32 }
%"class.RWTexture2D<vector<float, 4> >" = type { <4 x float> }

@"\01?Scene@@3URaytracingAccelerationStructure@@A" = external constant %dx.types.Handle, align 4
@"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" = external constant %dx.types.Handle, align 4

%struct.DispatchSystemData = type { i32 }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }

; Function Attrs: nounwind
declare !types !39 void @dx.op.traceRay.struct.RayPayload(i32, %dx.types.Handle, i32, i32, i32, i32, i32, float, float, float, float, float, float, float, float, %struct.RayPayload*) #0

; Function Attrs: nounwind readnone
declare %dx.types.Handle @dx.op.annotateHandle(i32, %dx.types.Handle, %dx.types.ResourceProperties) #1

; Function Attrs: nounwind readonly
declare %dx.types.Handle @dx.op.createHandleForLib.dx.types.Handle(i32, %dx.types.Handle) #2

; Function Attrs: nounwind
declare !types !40 void @dx.op.callShader.struct.TheirParams(i32, i32, %struct.TheirParams*) #0
declare !types !41 void @dx.op.callShader.struct.TheirParams2(i32, i32, %struct.TheirParams2*) #0

declare float @dx.op.rayTCurrent.f32(i32) #1
declare float @dx.op.rayTMin.f32(i32) #2
declare i32 @dx.op.hitKind.i32(i32) #2
declare i32 @dx.op.instanceID.i32(i32) #2
declare !types !42 i1 @dx.op.reportHit.struct.BuiltInTriangleIntersectionAttributes(i32, float, i32, %struct.BuiltInTriangleIntersectionAttributes*) #5

; Function Attrs: nounwind
define void @Intersection() #0 {
; CHECK-LABEL: define void @Intersection
; CHECK-SAME: () #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    [[TMP1:%.*]] = call float @lgc.rt.ray.tmin()
; CHECK-NEXT:    [[TMP2:%.*]] = call float @lgc.rt.ray.tcurrent()
; CHECK-NEXT:    [[TMP3:%.*]] = call i32 @lgc.rt.instance.id()
; CHECK-NEXT:    [[TMP4:%.*]] = call i32 @lgc.rt.hit.kind()
; CHECK-NEXT:    [[TMP5:%.*]] = alloca [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES:%.*]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = call i1 (...) @lgc.rt.report.hit(float 4.000000e+00, i32 0, ptr [[TMP5]], i32 8), !dxil.payload.type !25
; CHECK-NEXT:    ret void
;
  %1 = call float @dx.op.rayTMin.f32(i32 153)  ; RayTMin()
  %2 = call float @dx.op.rayTCurrent.f32(i32 154)  ; RayTCurrent()
  %3 = call i32 @dx.op.instanceID.i32(i32 141)  ; InstanceID()
  %4 = call i32 @dx.op.hitKind.i32(i32 143)  ; HitKind()
  %5 = alloca %struct.BuiltInTriangleIntersectionAttributes, align 4
  %6 = call i1 @dx.op.reportHit.struct.BuiltInTriangleIntersectionAttributes(i32 158, float 4.0, i32 0, %struct.BuiltInTriangleIntersectionAttributes* nonnull %5)  ; ReportHit(THit,HitKind,Attributes)
  ret void
}

define void @main() {
; CHECK-LABEL: define void @main() !lgc.rt.shaderstage !8 {
; CHECK-NEXT:    [[PARAMS:%.*]] = alloca [[STRUCT_THEIRPARAMS:%.*]], align 4
; CHECK-NEXT:    call void (...) @lgc.rt.call.callable.shader(i32 1, ptr [[PARAMS]], i32 256), !dxil.payload.type !26
; CHECK-NEXT:    ret void
;
  %params = alloca %struct.TheirParams, align 4
  call void @dx.op.callShader.struct.TheirParams(i32 159, i32 1, %struct.TheirParams* nonnull %params)  ; CallShader(ShaderIndex,Parameter)
  ret void
}

define void @mainTrace() {
; CHECK-LABEL: define void @mainTrace() !lgc.rt.shaderstage !8 {
; CHECK-NEXT:    [[TMP1:%.*]] = load [[DX_TYPES_HANDLE:%.*]], ptr @"\01?Scene@@3URaytracingAccelerationStructure@@A", align 4
; CHECK-NEXT:    [[TMP2:%.*]] = load [[DX_TYPES_HANDLE]], ptr @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A", align 4
; CHECK-NEXT:    [[TMP3:%.*]] = alloca [[STRUCT_RAYPAYLOAD:%.*]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT_RAYPAYLOAD]], ptr [[TMP3]], i32 0, i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = call [[DX_TYPES_HANDLE]] @dx.op.createHandleForLib.dx.types.Handle(i32 160, [[DX_TYPES_HANDLE]] [[TMP1]])
; CHECK-NEXT:    [[TMP6:%.*]] = call [[DX_TYPES_HANDLE]] @dx.op.annotateHandle(i32 216, [[DX_TYPES_HANDLE]] [[TMP5]], [[DX_TYPES_RESOURCEPROPERTIES:%.*]] { i32 16, i32 0 })
; CHECK-NEXT:    [[TMP7:%.*]] = call i64 @amd.dx.getAccelStructAddr([[DX_TYPES_HANDLE]] [[TMP6]])
; CHECK-NEXT:    call void (...) @lgc.rt.trace.ray(i64 [[TMP7]], i32 16, i32 -1, i32 0, i32 1, i32 0, <3 x float> zeroinitializer, float 0x3F50624DE0000000, <3 x float> <float 1.000000e+00, float 0.000000e+00, float 0.000000e+00>, float 1.000000e+04, ptr [[TMP3]], [1 x i32] [i32 272]), !dxil.payload.type !27
; CHECK-NEXT:    ret void
;
  %1 = load %dx.types.Handle, %dx.types.Handle* @"\01?Scene@@3URaytracingAccelerationStructure@@A", align 4
  %2 = load %dx.types.Handle, %dx.types.Handle* @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A", align 4
  %3 = alloca %struct.RayPayload, align 4
  %4 = getelementptr inbounds %struct.RayPayload, %struct.RayPayload* %3, i32 0, i32 0
  %5 = call %dx.types.Handle @dx.op.createHandleForLib.dx.types.Handle(i32 160, %dx.types.Handle %1)  ; CreateHandleForLib(Resource)
  %6 = call %dx.types.Handle @dx.op.annotateHandle(i32 216, %dx.types.Handle %5, %dx.types.ResourceProperties { i32 16, i32 0 })  ; AnnotateHandle(res,props)  resource: RTAccelerationStructure
  call void @dx.op.traceRay.struct.RayPayload(i32 157, %dx.types.Handle %6, i32 16, i32 -1, i32 0, i32 1, i32 0, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0x3F50624DE0000000, float 1.000000e+00, float 0.000000e+00, float 0.000000e+00, float 1.000000e+04, %struct.RayPayload* nonnull %3)  ; TraceRay(AccelerationStructure,RayFlags,InstanceInclusionMask,RayContributionToHitGroupIndex,MultiplierForGeometryContributionToShaderIndex,MissShaderIndex,Origin_X,Origin_Y,Origin_Z,TMin,Direction_X,Direction_Y,Direction_Z,TMax,payload)
  ret void
}

define void @called(%struct.MyParams* %arg) !types !38 {
; CHECK-LABEL: define void @called
; CHECK-SAME: (ptr [[ARG:%.*]]) !types !28 !lgc.rt.shaderstage !30 !dxil.payload.type !31 {
; CHECK-NEXT:    [[PARAMS:%.*]] = alloca [[STRUCT_THEIRPARAMS2:%.*]], align 4
; CHECK-NEXT:    call void (...) @lgc.rt.call.callable.shader(i32 2, ptr [[PARAMS]], i32 260), !dxil.payload.type !32
; CHECK-NEXT:    ret void
;
  %params = alloca %struct.TheirParams2, align 4
  call void @dx.op.callShader.struct.TheirParams2(i32 159, i32 2, %struct.TheirParams2* nonnull %params)  ; CallShader(ShaderIndex,Parameter)
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind readonly }

!llvm.ident = !{!0}
!dx.version = !{!1}
!dx.valver = !{!1}
!dx.shaderModel = !{!2}
!dx.entryPoints = !{!18, !5, !34, !36}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final)"}
!1 = !{i32 1, i32 6}
!2 = !{!"lib", i32 6, i32 6}
!3 = !{!4, !7, null, null}
!4 = !{!5}
!5 = !{void ()* @"main", !"main", null, null, !21}
!6 = !{i32 0, i32 4}
!7 = !{!8}
!8 = !{i32 0, %"class.RWTexture2D<vector<float, 4> >"* bitcast (%dx.types.Handle* @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" to %"class.RWTexture2D<vector<float, 4> >"*), !"RenderTarget", i32 0, i32 0, i32 1, i32 2, i1 false, i1 false, i1 false, !9}
!9 = !{i32 0, i32 9}
!11 = !{!12}
!12 = !{i32 1, !13, !13}
!13 = !{}
!14 = !{!12, !15, !16}
!15 = !{i32 2, !13, !13}
!16 = !{i32 0, !13, !13}
!17 = !{!12, !15}
!18 = !{null, !"", null, !3, !19}
!19 = !{i32 0, i64 65536}
!21 = !{i32 8, i32 7, i32 6, i32 16, i32 7, i32 8, i32 5, !22}
!22 = !{i32 0}
!24 = !{i32 8, i32 10, i32 6, i32 16, i32 7, i32 8, i32 5, !22}
!26 = !{i32 8, i32 8, i32 5, !22}
!28 = !{i32 8, i32 11, i32 6, i32 16, i32 5, !22}
!30 = !{i32 8, i32 7, i32 5, !22}
!31 = !{!32, !32, i64 0}
!32 = !{!"omnipotent char", !33, i64 0}
!33 = !{!"Simple C/C++ TBAA"}
!34 = !{void (%struct.MyParams*)* @called, !"called", null, null, !35}
!35 = !{i32 8, i32 12}
!36 = !{void ()* @mainTrace, !"mainTrace", null, null, !37}
!37 = !{i32 8, i32 7}
!38 = !{!"function", !"void", !43}
!39 = !{!"function", !"void", i32 poison, %dx.types.Handle poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, float poison, float poison, float poison, float poison, float poison, float poison, float poison, float poison, !44}
!40 = !{!"function", !"void", i32 poison, i32 poison, !45}
!41 = !{!"function", !"void", i32 poison, i32 poison, !46}
!42 = !{!"function", !"void", i32 poison, float poison, i32 poison, !47}
!43 = !{i32 0, %struct.MyParams poison}
!44 = !{i32 0, %struct.RayPayload poison}
!45 = !{i32 0, %struct.TheirParams poison}
!46 = !{i32 0, %struct.TheirParams2 poison}
!47 = !{i32 0, %struct.BuiltInTriangleIntersectionAttributes poison}
