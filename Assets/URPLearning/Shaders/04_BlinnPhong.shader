Shader "URPLearning/04_BlinnPhong"
{
    Properties
    {
        [MainTexture] _BaseMap ("Base Map", 2D) = "white" {}
        [MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _SpecColor ("Spec Color", Color) = (1, 1, 1, 1)
        _Smoothness ("Smoothness", Range(0.01, 1)) = 0.5
        _AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.12
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
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #include "Includes/URPLearningCommon.hlsl"
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST; half4 _BaseColor; half4 _SpecColor; half _Smoothness; half _AmbientStrength;
            CBUFFER_END
            VaryingsMinimal vert(AttributesMinimal input) { return VertMinimal(input, _BaseMap_ST); }
            half3 BlinnPhong(Light light, float3 n, float3 v, half3 albedo)
            {
                half3 h = normalize(light.direction + v);
                half ndotl = saturate(dot(n, light.direction));
                half spec = pow(saturate(dot(n, h)), exp2(10.0h * _Smoothness + 1.0h)) * _Smoothness;
                half3 radiance = light.color * light.distanceAttenuation * light.shadowAttenuation;
                return (albedo * ndotl + _SpecColor.rgb * spec) * radiance;
            }
            half4 frag(VaryingsMinimal input) : SV_Target
            {
                float3 n = normalize(input.normalWS);
                float3 v = GetWorldSpaceNormalizeViewDir(input.positionWS);
                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
                half3 color = BlinnPhong(mainLight, n, v, albedo.rgb) + SampleSH(n) * albedo.rgb * _AmbientStrength;
            #ifdef _ADDITIONAL_LIGHTS
                uint count = GetAdditionalLightsCount();
                for (uint i = 0; i < count; i++) color += BlinnPhong(GetAdditionalLight(i, input.positionWS), n, v, albedo.rgb);
            #endif
                return half4(color, albedo.a);
            }
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On ColorMask 0
            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            float3 _LightDirection; float3 _LightPosition;
            struct Attributes { float4 positionOS : POSITION; float3 normalOS : NORMAL; };
            struct Varyings { float4 positionCS : SV_POSITION; };
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
            #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                float3 lightDirectionWS = normalize(_LightPosition - positionWS);
            #else
                float3 lightDirectionWS = _LightDirection;
            #endif
                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
                return output;
            }
            half4 ShadowPassFragment(Varyings input) : SV_Target { return 0; }
            ENDHLSL
        }
    }
    FallBack Off
}
