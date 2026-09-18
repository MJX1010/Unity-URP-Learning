# URP Shader 骨架

每一份教学 Shader 都重复同一件事，先把这件事记死。

必须带 `Tags { "RenderPipeline" = "UniversalPipeline" }` 与 `LightMode = UniversalForward`。
材质参数进 `CBUFFER_START(UnityPerMaterial)`，贴图用 `TEXTURE2D` + `SAMPLER`。

Built-in → URP：CGPROGRAM→HLSLPROGRAM；UnityObjectToClipPos→TransformObjectToHClip；GetMainLight()。
