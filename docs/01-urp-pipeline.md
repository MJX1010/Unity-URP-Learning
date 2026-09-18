# URP 渲染流程原理

图形流水线：VS → 栅格 → FS。
URP：用 C# 编排本帧 Pass 与 RT。

链：URP Asset → UniversalRenderPipeline.Render → Camera Stack → UniversalRenderer → Pass / Feature。

默认 Forward：Shadow → Depth → Opaque → Sky → Copy → Transparent → Post → FinalBlit。

LightMode：UniversalForward / ShadowCaster / DepthOnly / DepthNormals / Meta / SRPDefaultUnlit。
