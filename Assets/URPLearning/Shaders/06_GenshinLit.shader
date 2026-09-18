Shader "URPLearning/06_GenshinLit"
{
    Properties
    {
        [MainTexture] _BaseMap ("Diffuse", 2D) = "white" {}
        [MainColor] _BaseColor ("Tint", Color) = (1, 1, 1, 1)
        _RampMap ("Ramp", 2D) = "white" {}
        _RampY ("Ramp Row (V)", Range(0.01, 0.99)) = 0.35
        _LightMap ("LightMap (R spec, G AO, B specMask)", 2D) = "white" {}
        _ShadowTint ("Shadow Tint", Color) = (0.7, 0.75, 0.9, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularPower ("Specular Power", Range(1, 128)) = 32
        _SpecularIntensity ("Specular Intensity", Range(0, 2)) = 0.6
        _RimColor ("Rim Color", Color) = (0.55, 0.75, 1, 1)
        _RimPower ("Rim Power", Range(0.5, 8)) = 3
        _RimIntensity ("Rim Intensity", Range(0, 2)) = 0.35
        _OutlineColor ("Outline Color", Color) = (0.05, 0.05, 0.08, 1)
        _OutlineWidth ("Outline Width", Range(0, 5)) = 1.2
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #include "Includes/URPLearningCommon.hlsl"
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_RampMap); SAMPLER(sampler_RampMap);
            TEXTURE2D(_LightMap); SAMPLER(sampler_LightMap);
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST; half4 _BaseColor; half _RampY; half4 _ShadowTint;
                half4 _SpecularColor; half _SpecularPower; half _SpecularIntensity;
                half4 _RimColor; half _RimPower; half _RimIntensity; half4 _OutlineColor; half _OutlineWidth;
            CBUFFER_END
            VaryingsMinimal vert(AttributesMinimal input) { return VertMinimal(input, _BaseMap_ST); }
            half4 frag(VaryingsMinimal input) : SV_Target
            {
                float3 n = normalize(input.normalWS);
                float3 v = GetWorldSpaceNormalizeViewDir(input.positionWS);
                Light light = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
                half4 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                half4 lm = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv);
                half halfLambert = dot(n, light.direction) * 0.5h + 0.5h;
                half3 ramp = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(saturate(halfLambert * lm.g), _RampY)).rgb;
                ramp = lerp(_ShadowTint.rgb, ramp, saturate(lm.g + 0.2h));
                half specTerm = pow(saturate(dot(n, normalize(light.direction + v))), _SpecularPower);
                specTerm = step(1.0h - lm.b, specTerm) * specTerm;
                half3 spec = _SpecularColor.rgb * specTerm * lm.r * _SpecularIntensity;
                half3 rim = _RimColor.rgb * pow(1.0h - saturate(dot(n, v)), _RimPower) * saturate(dot(n, light.direction)) * _RimIntensity;
                return half4(baseCol.rgb * ramp * light.color + spec + rim, baseCol.a);
            }
            ENDHLSL
        }
        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "SRPDefaultUnlit" }
            Cull Front ZWrite On
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST; half4 _BaseColor; half _RampY; half4 _ShadowTint;
                half4 _SpecularColor; half _SpecularPower; half _SpecularIntensity;
                half4 _RimColor; half _RimPower; half _RimIntensity; half4 _OutlineColor; half _OutlineWidth;
            CBUFFER_END
            struct Attributes { float4 positionOS : POSITION; float3 normalOS : NORMAL; float4 color : COLOR; };
            struct Varyings { float4 positionCS : SV_POSITION; };
            Varyings vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs pos = GetVertexPositionInputs(input.positionOS.xyz);
                float3 normalVS = TransformWorldToViewDir(TransformObjectToWorldNormal(input.normalOS), true);
                output.positionCS = pos.positionCS;
                output.positionCS.xy += normalize(normalVS.xy) * (_OutlineWidth * 0.002 * input.color.a) * output.positionCS.w;
                return output;
            }
            half4 frag(Varyings input) : SV_Target { return _OutlineColor; }
            ENDHLSL
        }
    }
    FallBack Off
}
