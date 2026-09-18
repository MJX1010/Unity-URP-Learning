Shader "URPLearning/06_GenshinFace"
{
    Properties
    {
        [MainTexture] _BaseMap ("Face Diffuse", 2D) = "white" {}
        [MainColor] _BaseColor ("Tint", Color) = (1, 1, 1, 1)
        _FaceShadowMap ("SDF Face Shadow", 2D) = "gray" {}
        _RampMap ("Ramp", 2D) = "white" {}
        _RampY ("Ramp Row (V)", Range(0.01, 0.99)) = 0.15
        _FaceShadowSoft ("SDF Softness", Range(0.001, 0.2)) = 0.03
        _LightDirOffset ("Light Horizontal (script)", Range(-1, 1)) = 0
        _RimColor ("Rim Color", Color) = (1, 0.85, 0.8, 1)
        _RimPower ("Rim Power", Range(0.5, 8)) = 4
        _RimIntensity ("Rim Intensity", Range(0, 2)) = 0.15
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
            #include "Includes/URPLearningCommon.hlsl"
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_FaceShadowMap); SAMPLER(sampler_FaceShadowMap);
            TEXTURE2D(_RampMap); SAMPLER(sampler_RampMap);
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST; half4 _BaseColor; half _RampY; half _FaceShadowSoft; half _LightDirOffset;
                half4 _RimColor; half _RimPower; half _RimIntensity;
            CBUFFER_END
            VaryingsMinimal vert(AttributesMinimal input) { return VertMinimal(input, _BaseMap_ST); }
            half4 frag(VaryingsMinimal input) : SV_Target
            {
                half4 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                Light light = GetMainLight();
                half sdfL = SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, input.uv).r;
                half sdfR = SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(1.0 - input.uv.x, input.uv.y)).r;
                half sdf = lerp(sdfR, sdfL, step(0.0h, _LightDirOffset));
                half threshold = abs(_LightDirOffset);
                half shadow = smoothstep(threshold - _FaceShadowSoft, threshold + _FaceShadowSoft, sdf);
                half3 ramp = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(shadow, _RampY)).rgb;
                half3 diffuse = baseCol.rgb * lerp(ramp, light.color, shadow * 0.35h + 0.65h);
                float3 n = normalize(input.normalWS);
                float3 v = GetWorldSpaceNormalizeViewDir(input.positionWS);
                half3 rim = _RimColor.rgb * pow(1.0h - saturate(dot(n, v)), _RimPower) * _RimIntensity * shadow;
                return half4(diffuse + rim, baseCol.a);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
