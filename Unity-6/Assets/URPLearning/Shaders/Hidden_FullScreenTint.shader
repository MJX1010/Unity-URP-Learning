Shader "Hidden/URPLearning/FullScreenTint"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off
        ZTest Always
        Cull Off
        Pass
        {
            Name "Tint"
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            float4 _TintColor;
            float _TintIntensity;
            half4 Frag(Varyings input) : SV_Target
            {
                half4 src = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, input.texcoord);
                return lerp(src, src * half4(_TintColor.rgb, 1), _TintIntensity);
            }
            ENDHLSL
        }
    }
}
