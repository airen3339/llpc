#version 450 core

layout(set = 0, binding = 0) uniform sampler2DArray samp;
layout(location = 0) out vec4 oColor;

void main()
{
    oColor = texture(samp, vec3(1, 2, 3));
}


// BEGIN_SHADERTEST
/*
; RUN: amdllpc -spvgen-dir=%spvgendir% -v %gfxip %s | FileCheck -check-prefix=SHADERTEST %s
; SHADERTEST-LABEL: {{^// LLPC}} SPIRV-to-LLVM translation results
; SHADERTEST: AMDLLPC SUCCESS
*/
// END_SHADERTEST
