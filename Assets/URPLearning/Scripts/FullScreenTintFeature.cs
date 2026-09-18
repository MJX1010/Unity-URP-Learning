using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPLearning
{
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
            Settings _settings;
            Material _material;

            public TintPass(Settings settings)
            {
                _settings = settings;
                renderPassEvent = settings.passEvent;
            }

            public void Setup(Settings settings)
            {
                _settings = settings;
                renderPassEvent = settings.passEvent;
            }

            Material GetMaterial()
            {
                if (_material != null) return _material;
                Shader shader = Shader.Find("Hidden/URPLearning/FullScreenTint");
                if (shader == null) return null;
                _material = CoreUtils.CreateEngineMaterial(shader);
                return _material;
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                Material mat = GetMaterial();
                if (mat == null) return;
                mat.SetColor(ColorId, _settings.color);
                mat.SetFloat(IntensityId, _settings.intensity);
                CommandBuffer cmd = CommandBufferPool.Get(ProfilerTag);
                RenderTargetIdentifier source = renderingData.cameraData.renderer.cameraColorTargetHandle;
                cmd.Blit(source, source, mat, 0);
                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }
        }
    }
}
