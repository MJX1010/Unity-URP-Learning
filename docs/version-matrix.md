# 2022.3.62f3 vs Unity 6

| 点 | 2022.3.62f3（URP 14） | Unity 6（URP 17） |
| --- | --- | --- |
| 自定义 Pass 入口 | `ScriptableRenderPass.Execute` | `RecordRenderGraph` |
| 相机颜色 | `renderer.cameraColorTargetHandle` | `UniversalResourceData.activeColorTexture` |
| 全屏拷贝 | `cmd.Blit` | `Blitter.BlitTexture` + 临时 RT |
| Shader 包路径 | `Packages/com.unity.render-pipelines.universal/ShaderLibrary/` | 相同 |
| Hidden 全屏 Shader | `_MainTex` | `_BlitTexture` / `Blit.hlsl` |

Shader 本体两边共用。分叉的是 Renderer Feature 和 Hidden Shader。
