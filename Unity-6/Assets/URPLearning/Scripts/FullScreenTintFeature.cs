using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

namespace URPLearning
{
    /// <summary>
    /// Unity 6 / URP 17 Render Graph fullscreen tint. Do not copy to 2022.3.
    /// </summary>
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
        Material _material;

        public override void Create()
        {
            Shader shader = Shader.Find("Hidden/URPLearning/FullScreenTint");
            if (shader != null)
                _material = CoreUtils.CreateEngineMaterial(shader);
            _pass = new TintPass();
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (renderingData.cameraData.cameraType == CameraType.Preview || _material == null)
                return;
            _pass.Setup(settings, _material);
            renderer.EnqueuePass(_pass);
        }

        protected override void Dispose(bool disposing)
        {
            CoreUtils.Destroy(_material);
        }

        class TintPass : ScriptableRenderPass
        {
            class PassData
            {
                public TextureHandle source;
                public Material material;
            }

            Settings _settings;
            Material _material;
            static readonly int ColorId = Shader.PropertyToID("_TintColor");
            static readonly int IntensityId = Shader.PropertyToID("_TintIntensity");

            public void Setup(Settings settings, Material material)
            {
                _settings = settings;
                _material = material;
                renderPassEvent = settings.passEvent;
                requiresIntermediateTexture = true;
            }

            public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
            {
                if (_material == null) return;
                UniversalResourceData resources = frameData.Get<UniversalResourceData>();
                TextureHandle cameraColor = resources.activeColorTexture;
                if (!cameraColor.IsValid()) return;

                TextureDesc desc = renderGraph.GetTextureDesc(cameraColor);
                desc.name = "_URPLearningTintTemp";
                desc.clearBuffer = false;
                desc.msaaSamples = MSAASamples.None;
                desc.depthBufferBits = 0;
                TextureHandle temp = renderGraph.CreateTexture(desc);

                _material.SetColor(ColorId, _settings.color);
                _material.SetFloat(IntensityId, _settings.intensity);

                using (var builder = renderGraph.AddRasterRenderPass<PassData>("URPLearning Tint Apply", out PassData data))
                {
                    data.source = cameraColor;
                    data.material = _material;
                    builder.UseTexture(cameraColor, AccessFlags.Read);
                    builder.SetRenderAttachment(temp, 0, AccessFlags.Write);
                    builder.AllowPassCulling(false);
                    builder.SetRenderFunc((PassData d, RasterGraphContext ctx) =>
                    {
                        Blitter.BlitTexture(ctx.cmd, d.source, new Vector4(1f, 1f, 0f, 0f), d.material, 0);
                    });
                }

                using (var builder = renderGraph.AddRasterRenderPass<PassData>("URPLearning Tint Restore", out PassData data))
                {
                    data.source = temp;
                    builder.UseTexture(temp, AccessFlags.Read);
                    builder.SetRenderAttachment(cameraColor, 0, AccessFlags.Write);
                    builder.AllowPassCulling(false);
                    builder.SetRenderFunc((PassData d, RasterGraphContext ctx) =>
                    {
                        Blitter.BlitTexture(ctx.cmd, d.source, new Vector4(1f, 1f, 0f, 0f), 0, false);
                    });
                }
            }
        }
    }
}
