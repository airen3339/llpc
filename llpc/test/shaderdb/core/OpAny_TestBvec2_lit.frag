// NOTE: Assertions have been autogenerated by tool/update_llpc_test_checks.py
// RUN: amdllpc -o - -gfxip 10.1 -emit-lgc %s | FileCheck -check-prefixes=CHECK %s

#version 450

layout(binding = 0) uniform Uniforms
{
    bvec2 b2;
};

layout(location = 0) out vec4 fragColor;

void main()
{
    vec4 color = vec4(0.5);

    if (any(b2) == true)
    {
        color = vec4(1.0);
    }

    fragColor = color;
}
// CHECK-LABEL: @lgc.shader.FS.main(
// CHECK-NEXT:  .entry:
// CHECK-NEXT:    [[TMP0:%.*]] = call ptr addrspace(7) (...) @lgc.create.load.buffer.desc.p7(i32 0, i32 0, i32 0, i32 0)
// CHECK-NEXT:    [[TMP1:%.*]] = call ptr @llvm.invariant.start.p7(i64 -1, ptr addrspace(7) [[TMP0]])
// CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i32>, ptr addrspace(7) [[TMP0]], align 8
// CHECK-NEXT:    [[TMP3:%.*]] = icmp ne <2 x i32> [[TMP2]], zeroinitializer
// CHECK-NEXT:    [[TMP4:%.*]] = extractelement <2 x i1> [[TMP3]], i64 0
// CHECK-NEXT:    [[TMP5:%.*]] = extractelement <2 x i1> [[TMP3]], i64 1
// CHECK-NEXT:    [[TMP6:%.*]] = or i1 [[TMP4]], [[TMP5]]
// CHECK-NEXT:    [[TMP7:%.*]] = freeze i1 [[TMP6]]
// CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[TMP7]], <4 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>, <4 x float> <float 5.000000e-01, float 5.000000e-01, float 5.000000e-01, float 5.000000e-01>
// CHECK-NEXT:    call void (...) @lgc.create.write.generic.output(<4 x float> [[SPEC_SELECT]], i32 0, i32 0, i32 0, i32 0, i32 0, i32 poison)
// CHECK-NEXT:    ret void
//
