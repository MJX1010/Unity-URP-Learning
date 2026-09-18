# Unity URP Learning

面向 **Unity 2022.3 LTS / URP 14+** 的学习仓库：把三条 B 站 URP 课程的主题拆成可对照的原理笔记，并配上可直接拖进 URP 工程的手写 Shader / Renderer Feature Demo。

> 本仓库是学习笔记 + 可运行示例，**不是**对原视频的逐字抄录或官方课件镜像。原课程版权归 UP 主所有，请以原视频为准做对照学习。

## 仓库结构

```
docs/                         原理与视频对照
Assets/URPLearning/
  Shaders/                    手写 Shader
  Shaders/Includes/           公共 HLSL
  Scripts/                    Renderer Feature / Pass
  Materials/                  材质使用说明
  Scenes/                     场景搭建说明
```

## 对应视频（验证结论）

| 视频 | 链接 | 验证状态 | 本仓库对应 |
| --- | --- | --- | --- |
| URP 的渲染流程的理解 · 像灰一样 | https://www.bilibili.com/video/BV18P4y1k7zu | 已核对标题 / UP / 时长 08:10 | `docs/00-video-notes.md`、`docs/01-urp-pipeline.md`、`FullScreenTintFeature` |
| Unity URP Shader 入门到精通｜从渲染管线到手写自定义 PBR | https://b23.tv/fG00XwJ | 短链元数据不稳定；主题按标题拆解 | Unlit → Lambert → Blinn-Phong → Custom PBR |
| Unity URP Shader 入门精要：从零复刻原神渲染 · 砂塘学徒 | 约 2h46m | 已核对 UP 与超长单集形态 | `GenshinLit.shader` + `docs/05-genshin-npr.md` |

详细验证过程见 [docs/00-video-notes.md](docs/00-video-notes.md)。

## 推荐学习顺序

1. 用 Unity Hub 新建 **3D (URP)** 工程，把 `Assets/URPLearning` 拷进去。
2. 读 [docs/01-urp-pipeline.md](docs/01-urp-pipeline.md)。
3. 读 [docs/02-urp-usage.md](docs/02-urp-usage.md)。
4. 按 Shader 难度打开材质：Unlit → Lambert → BlinnPhong → CustomPBR → GenshinLit / Face。
5. 把 `FullScreenTintFeature` 加到 URP Renderer 上。

## 环境

- Unity 2022.3.x 或 Unity 6
- Universal RP 已安装
- Color Space 建议 Linear
