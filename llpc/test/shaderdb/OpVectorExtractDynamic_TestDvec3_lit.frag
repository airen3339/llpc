#version 450

layout(binding = 0) uniform Uniforms
{
    dvec3 d3;
    double d1_1;

    int i;
};

layout(location = 0) out vec4 fragColor;

void main()
{
    vec4 color = vec4(0.5);

    double d1_0 = d3.zyx[i];

    if (d1_0 == d1_1)
    {
        color = vec4(1.0);
    }

    fragColor = color;
}
// BEGIN_SHADERTEST
/*
; RUN: amdllpc -spvgen-dir=%spvgendir% -v %gfxip %s | FileCheck -check-prefix=SHADERTEST %s
; SHADERTEST-LABEL: {{^// LLPC}} SPIRV-to-LLVM translation results
; SHADERTEST: %{{[^ ]+}} = extractelement <3 x i32> <i32 2, i32 1, i32 0>, i32 %{{[A-Za-z0-9_.]+}}
; SHADERTEST: AMDLLPC SUCCESS
*/
// END_SHADERTEST
