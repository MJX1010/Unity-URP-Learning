Shader "URPLearning/03_Lambert"
{
    Properties
    {
        [MainTexture] _BaseMap ("Base Map", 2D) = "white" {}
        [MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [Toggle(_HALF_LAMBERT)] _HalfLambert ("Half Lambert", Float) = 1
        _AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.15
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _HALF_LAMBERT
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #include "Includes/URPLearningCommon.hlsl"
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half _AmbientStrength;
            CBUFFER_END
            VaryingsMinimal vert(AttributesMinimal input) { return VertMinimal(input, _BaseMap_ST); }
            half4 frag(VaryingsMinimal input) : SV_Target
            {
                float3 n = normalize(input.normalWS);
                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
                half ndotl = dot(n, mainLight.direction);
            #ifdef _HALF_LAMBERT
                ndotl = ndotl * 0.5h + 0.5h;
            #else
                ndotl = saturate(ndotl);
            #endif
                half3 radiance = mainLight.color * mainLight.distanceAttenuation * mainLight.shadowAttenuation;
                half3 color = albedo.rgb * (radiance * ndotl + SampleSH(n) * _AmbientStrength + AdditionalLightingDiffuse(input.positionWS, n));
                return half4(color, albedo.a);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
