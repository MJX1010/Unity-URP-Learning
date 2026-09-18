using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPLearning
{
    /// <summary>Unity 2022.3.62f3 / URP 14 Execute + Blit.</summary>
    public class FullScreenTintFeature : ScriptableRendererFeature
    {
        [System.Serializable]
        public class Settings
        {
            public RenderPassEvent passEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            public Color color = new Color(1f, 0.85f, 0.7f, 1f);
            [Range(0f, 1f)] public float intensity = 0.15f;
        }
        public Settings settings = new Settings();
        TintPass _pass;
        public override void Create() { _pass = new TintPass(settings); }
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (renderingData.cameraData.cameraType == CameraType.Preview) return;
            _pass.Setup(settings);
            renderer.EnqueuePass(_pass);
        }
        class TintPass : ScriptableRenderPass
        {
            const string ProfilerTag = "URPLearning Fullscreen Tint";
            static readonly int ColorId = Shader.PropertyToID("_TintColor");
            static readonly int IntensityId = Shader.PropertyToID("_TintIntensity");
            Settings _settings; Material _material;
            public TintPass(Settings settings) { _settings = settings; renderPassEvent = settings.passEvent; }
            public void Setup(Settings settings) { _settings = settings; renderPassEvent = settings.passEvent; }
            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                if (_material == null)
                {
                    Shader shader = Shader.Find("Hidden/URPLearning/FullScreenTint");
                    if (shader == null) return;
                    _material = CoreUtils.CreateEngineMaterial(shader);
                }
                _material.SetColor(ColorId, _settings.color);
                _material.SetFloat(IntensityId, _settings.intensity);
                CommandBuffer cmd = CommandBufferPool.Get(ProfilerTag);
                cmd.Blit(renderingData.cameraData.renderer.cameraColorTargetHandle, renderingData.cameraData.renderer.cameraColorTargetHandle, _material, 0);
                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }
        }
    }
}
