Shader "URPLearning/05_CustomPBR"
{
    Properties
    {
        [MainTexture] _BaseMap ("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor ("Albedo Color", Color) = (1, 1, 1, 1)
        _Metallic ("Metallic", Range(0, 1)) = 0.0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _Occlusion ("Occlusion", Range(0, 1)) = 1.0
        [HDR] _EmissionColor ("Emission", Color) = (0, 0, 0, 1)
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
                float4 _BaseMap_ST; half4 _BaseColor; half _Metallic; half _Smoothness; half _Occlusion; half4 _EmissionColor;
            CBUFFER_END
            VaryingsMinimal vert(AttributesMinimal input) { return VertMinimal(input, _BaseMap_ST); }
            half D_GGX(half ndoth, half roughness)
            {
                half a = roughness * roughness; half a2 = a * a;
                half d = (ndoth * ndoth * (a2 - 1.0h) + 1.0h);
                return a2 / max(PI * d * d, 1e-7h);
            }
            half G_SchlickGGX(half ndotx, half roughness)
            {
                half r = roughness + 1.0h; half k = (r * r) / 8.0h;
                return ndotx / max(ndotx * (1.0h - k) + k, 1e-7h);
            }
            half3 F_Schlick(half3 f0, half vdotH)
            {
                return f0 + (1.0h - f0) * pow(saturate(1.0h - vdotH), 5.0h);
            }
            half3 DirectPBR(Light light, half3 albedo, half3 n, half3 v, half metallic, half roughness)
            {
                half3 l = light.direction; half3 h = normalize(l + v);
                half ndotl = saturate(dot(n, l)); half ndotv = saturate(dot(n, v));
                half ndoth = saturate(dot(n, h)); half vdoth = saturate(dot(v, h));
                half3 f0 = lerp(half3(0.04h, 0.04h, 0.04h), albedo, metallic);
                half3 F = F_Schlick(f0, vdoth);
                half D = D_GGX(ndoth, roughness);
                half G = G_SchlickGGX(ndotl, roughness) * G_SchlickGGX(ndotv, roughness);
                half3 spec = (D * F * G) / max(4.0h * ndotl * ndotv, 1e-7h);
                half3 diff = (1.0h - F) * (1.0h - metallic) * albedo / PI;
                half3 radiance = light.color * light.distanceAttenuation * light.shadowAttenuation;
                return (diff + spec) * radiance * ndotl;
            }
            half4 frag(VaryingsMinimal input) : SV_Target
            {
                float3 n = normalize(input.normalWS);
                float3 v = GetWorldSpaceNormalizeViewDir(input.positionWS);
                half4 albedoTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                half3 albedo = albedoTex.rgb * _BaseColor.rgb;
                half roughness = max(1.0h - _Smoothness, 0.04h);
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
                half3 color = DirectPBR(mainLight, albedo, n, v, _Metallic, roughness);
            #ifdef _ADDITIONAL_LIGHTS
                uint count = GetAdditionalLightsCount();
                for (uint i = 0; i < count; i++) color += DirectPBR(GetAdditionalLight(i, input.positionWS), albedo, n, v, _Metallic, roughness);
            #endif
                half3 f0 = lerp(half3(0.04h, 0.04h, 0.04h), albedo, _Metallic);
                half ndotv = saturate(dot(n, v));
                half3 F = f0 + (max(1.0h - roughness, f0) - f0) * pow(1.0h - ndotv, 5.0h);
                half3 specIBL = GlossyEnvironmentReflection(reflect(-v, n), roughness, 1.0h);
                half3 indirect = (SampleSH(n) * albedo * (1.0h - _Metallic) * (1.0h - F) + specIBL * F) * _Occlusion;
                return half4(color + indirect + _EmissionColor.rgb, albedoTex.a * _BaseColor.a);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
