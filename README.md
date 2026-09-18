# Unity URP Learning

按 **编辑器版本** 分目录，不要混用。

| 目录 | Unity | URP | 自定义 Pass |
| --- | --- | --- | --- |
| [Unity-2022.3.62f3](Unity-2022.3.62f3/) | 2022.3.62f3 LTS | 14.x | `Execute` + `cameraColorTargetHandle` + `CommandBuffer.Blit` |
| [Unity-6](Unity-6/) | Unity 6 / 6000.x | 17.x | `RecordRenderGraph` + `Blitter` + `TextureHandle` |

两套都包含同一套手写 Shader：Unlit → Lambert → Blinn-Phong → Custom PBR → NPR，以及全屏 Tint Feature。

## 怎么用

1. 用对应版本的 Unity Hub 新建 **3D (URP)** 工程。
2. 只拷对应目录里的 `Assets/URPLearning` 到工程 `Assets/`。
3. 先看该目录下的 `README.md` 和 `docs/`。

不要把 2022 的 Feature 丢进 Unity 6；也不要把 Unity 6 的 Render Graph 脚本丢进 2022.3。

版本差异见 [docs/version-matrix.md](docs/version-matrix.md)。

根目录旧的 `Assets/` 保留作兼容，以版本目录为准。
