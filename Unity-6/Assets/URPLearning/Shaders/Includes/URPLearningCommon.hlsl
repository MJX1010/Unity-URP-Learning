#ifndef URP_LEARNING_COMMON_INCLUDED
#define URP_LEARNING_COMMON_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#ifndef PI
#define PI 3.14159265359
#endif
struct AttributesMinimal { float4 positionOS : POSITION; float3 normalOS : NORMAL; float2 uv : TEXCOORD0; };
struct VaryingsMinimal { float4 positionCS : SV_POSITION; float2 uv : TEXCOORD0; float3 positionWS : TEXCOORD1; float3 normalWS : TEXCOORD2; };
float2 TransformUV(float2 uv, float4 st) { return uv * st.xy + st.zw; }
VaryingsMinimal VertMinimal(AttributesMinimal input, float4 baseMapST)
{
    VaryingsMinimal output;
    VertexPositionInputs pos = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs nor = GetVertexNormalInputs(input.normalOS);
    output.positionCS = pos.positionCS;
    output.positionWS = pos.positionWS;
    output.normalWS = nor.normalWS;
    output.uv = TransformUV(input.uv, baseMapST);
    return output;
}
half3 AdditionalLightingDiffuse(float3 positionWS, float3 normalWS)
{
    half3 color = 0;
#ifdef _ADDITIONAL_LIGHTS
    uint count = GetAdditionalLightsCount();
    for (uint i = 0; i < count; i++)
    {
        Light light = GetAdditionalLight(i, positionWS);
        color += light.color * light.distanceAttenuation * light.shadowAttenuation * saturate(dot(normalWS, light.direction));
    }
#endif
    return color;
}
#endif
