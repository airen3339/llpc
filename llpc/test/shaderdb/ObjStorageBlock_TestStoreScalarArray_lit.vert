#version 450 core

layout(std430, binding = 0) buffer Block
{
    int   i;
    float f1[2];
} block;

void main()
{
    int i = block.i;
    float f1[2];
    f1[0] = float(i);
    f1[1] = 2.0;
    block.f1 = f1;

    gl_Position = vec4(1.0);
}
// BEGIN_SHADERTEST
/*
; RUN: amdllpc -spvgen-dir=%spvgendir% -v %gfxip %s | FileCheck -check-prefix=SHADERTEST %s

; SHADERTEST-LABEL: {{^// LLPC}} pipeline patching results
; SHADERTEST: call void @llvm.amdgcn.raw.buffer.store.i32(i32 %{{[^, ]+}}, <4 x i32> %{{[^, ]+}}, i32 4, i32 0, i32 0)
; SHADERTEST: call void @llvm.amdgcn.raw.buffer.store.i32(i32 1073741824, <4 x i32> %{{[^, ]+}}, i32 8, i32 0, i32 0)

; SHADERTEST: AMDLLPC SUCCESS
*/
// END_SHADERTEST
