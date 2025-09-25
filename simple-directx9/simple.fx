// simple.fx  (UTF-8, BOMなし)
// 依存行列は g_matWorldViewProj のみ（元の設計に合わせる）

float4x4 g_matWorldViewProj;
float4 g_lightNormal = { 0.3f, 1.0f, 0.5f, 0.0f }; // オブジェクト空間のライト方向

texture texture1;
sampler textureSampler = sampler_state
{
    Texture = (texture1);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float g_t = 0.0f;
float g_normalEps = 0.5f; // 頂点ピッチに合わせ 0.02〜0.2 くらいで調整

float g_height = 0.4f;

// 元の波変形ロジック（オブジェクト空間）を関数化
float3 DeformObj(float3 p)
{
    float3 q = p;

    q.y += sin(g_t + q.x * 0.2) * 0.3f;
    q.x += cos(g_t + q.x * 0.2) * 0.3f;

    q.y += sin(g_t + q.z * 0.3) * 0.3f;
    q.z += cos(g_t + q.z * 0.3) * 0.3f;

    float g_t2 = (g_t * 1.2) + q.x + q.z;
    q.y += sin(g_t2 + q.x * 8.1) * 0.01f;
    q.x += cos(g_t2 + q.x * 8.1) * 0.01f;
    q.y += sin(g_t2 + q.z * 8.1) * 0.01f;
    q.z += cos(g_t2 + q.z * 8.1) * 0.01f;

    float g_t3 = (g_t * 0.7) + q.x + q.z;
    q.y += sin(g_t3 + q.x * 0.7) * 0.1f;
    q.x += cos(g_t3 + q.x * 0.7) * 0.3f;
    q.y += sin(g_t3 + q.z * 0.5) * 0.1f;
    q.z += cos(g_t3 + q.z * 0.5) * 0.3f;

    float g_t4 = (g_t * 1.8) + q.z * q.z;
    q.y += sin(g_t4 + q.x * q.z * 5) * 0.005f;
    q.x += cos(g_t4 + q.x * q.z * 5) * 0.02f;
    q.y += sin(g_t4 + q.z * q.z * 5) * 0.015f;
    q.z += cos(g_t4 + q.z * q.z * 5) * 0.02f;

    float g_t5 = (g_t * 1.5) + q.x;
    q.y += sin(g_t5 + q.x) * 0.2f;
    q.x += cos(g_t5 + q.x) * 0.2f;
    q.y += sin(g_t5 + q.z) * 0.2f;
    q.z += cos(g_t5 + q.z) * 0.2f;

    float g_t6 = (g_t * 1.7) + q.z;
    q.y += sin(g_t6 + q.x * 0.3) * 0.1f;
    q.x += cos(g_t6 + q.x * 0.3) * 0.3f;
    q.y += sin(g_t6 + q.z * 0.4) * 0.1f;
    q.z += cos(g_t6 + q.z * 0.4) * 0.3f;

    q.y *= g_height;

    return q;
}

void VertexShader1(
    in float4 inPosition : POSITION,
    in float4 inNormal : NORMAL0,
    in float4 inTexCood : TEXCOORD0,

    out float4 outPosition : POSITION,
    out float4 outDiffuse : COLOR0,
    out float2 outTexCood : TEXCOORD0
)
{
    // 位置を波で変形（オブジェクト空間）
    float3 p0 = inPosition.xyz;
    float3 p = DeformObj(p0);

    // 透視変換（従来通り g_matWorldViewProj のみ）
    outPosition = mul(float4(p, 1.0f), g_matWorldViewProj);

    // --- 法線の再計算（オブジェクト空間・有限差分）---
    float eps = g_normalEps;

    float3 px = DeformObj(p0 + float3(eps, 0.0f, 0.0f));
    float3 pz = DeformObj(p0 + float3(0.0f, 0.0f, eps));

    float3 Tx = px - p; // ∂p/∂x0
    float3 Tz = pz - p; // ∂p/∂z0

    // 数値安定化（ごく稀に同一点になるのを防止）
    if (dot(Tx, Tx) < 1e-8)
    {
        Tx = float3(1.0f, 0.0f, 0.0f);
    }
    if (dot(Tz, Tz) < 1e-8)
    {
        Tz = float3(0.0f, 0.0f, 1.0f);
    }

    // 交差の向きに注意：裏返る場合は cross(Tx, Tz) に変更
    float3 N = normalize(cross(Tz, Tx));

    // 頂点ライティング（ライトは同じくオブジェクト空間とみなす）
    float3 L = normalize(g_lightNormal.xyz);
    float ndotl = saturate(dot(N, L));
    outDiffuse = float4(ndotl, ndotl, ndotl, 1.0f);

    outTexCood = inTexCood.xy;
}

void PixelShader1(
    in float4 inScreenColor : COLOR0,
    in float2 inTexCood : TEXCOORD0,

    out float4 outColor : COLOR
)
{
    float4 albedo = tex2D(textureSampler, inTexCood);
    outColor = inScreenColor * albedo;
}

technique Technique1
{
    pass Pass1
    {
        VertexShader = compile vs_3_0 VertexShader1();
        PixelShader = compile ps_3_0 PixelShader1();
    }
}
