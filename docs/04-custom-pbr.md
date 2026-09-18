# 手写 URP PBR

金属度 / 粗糙度工作流 + Cook-Torrance。

F0 = lerp(0.04, albedo, metallic)

fs = D*F*G / (4 * NdotL * NdotV)

D=GGX, F=Schlick, G=Smith-Schlick GGX。
