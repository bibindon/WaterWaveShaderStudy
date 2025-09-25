float4x4 g_matWorldViewProj;
float4 g_lightNormal = { 0.3f, 1.0f, 0.5f, 0.0f };

texture texture1;
sampler textureSampler = sampler_state {
    Texture = (texture1);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float g_t = 0.0f;
void VertexShader1(in  float4 inPosition  : POSITION,
                   in  float4 inNormal    : NORMAL0,
                   in  float4 inTexCood   : TEXCOORD0,

                   out float4 outPosition : POSITION,
                   out float4 outDiffuse  : COLOR0,
                   out float4 outTexCood  : TEXCOORD0)
{
    inPosition.y += sin(g_t + inPosition.x * 0.2) * 0.3f;
    inPosition.x += cos(g_t + inPosition.x * 0.2) * 0.3f;

    inPosition.y += sin(g_t + inPosition.z * 0.3) * 0.3f;
    inPosition.z += cos(g_t + inPosition.z * 0.3) * 0.3f;

    float g_t2 = (g_t * 1.2) + 1.2;
    inPosition.y += sin(g_t2 + inPosition.x * 8.1) * 0.02f;
    inPosition.x += cos(g_t2 + inPosition.x * 8.1) * 0.01f;

    inPosition.y += sin(g_t2 + inPosition.z * 8.1) * 0.02f;
    inPosition.z += cos(g_t2 + inPosition.z * 8.1) * 0.01f;

    float g_t3 = (g_t * 0.7) + 0.7;
    inPosition.y += sin(g_t3 + inPosition.x * 0.7) * 0.3f;
    inPosition.x += cos(g_t3 + inPosition.x * 0.7) * 0.3f;

    inPosition.y += sin(g_t3 + inPosition.z * 0.5) * 0.3f;
    inPosition.z += cos(g_t3 + inPosition.z * 0.5) * 0.3f;

    float g_t4 = (g_t * 1.8) + 0.8;
    inPosition.y += sin(g_t4 + inPosition.x * 55.7) * 0.01f;
    inPosition.x += cos(g_t4 + inPosition.x * 55.7) * 0.01f;

    inPosition.y += sin(g_t4 + inPosition.z * 30.5) * 0.01f;
    inPosition.z += cos(g_t4 + inPosition.z * 30.5) * 0.01f;

    float g_t5 = (g_t + 1.5) * 0.7;
    inPosition.y += sin(g_t5 + inPosition.x) * 0.2f;
    inPosition.x += cos(g_t5 + inPosition.x) * 0.2f;

    inPosition.y += sin(g_t5 + inPosition.z) * 0.2f;
    inPosition.z += cos(g_t5 + inPosition.z) * 0.2f;

    float g_t6 = (g_t * 1.7) + 1.7;
    inPosition.y += sin(g_t6 + inPosition.x * 0.3) * 0.3f;
    inPosition.x += cos(g_t6 + inPosition.x * 0.3) * 0.3f;

    inPosition.y += sin(g_t6 + inPosition.z * 0.4) * 0.3f;
    inPosition.z += cos(g_t6 + inPosition.z * 0.4) * 0.3f;

    outPosition = mul(inPosition, g_matWorldViewProj);

    float lightIntensity = dot(inNormal, g_lightNormal);
    outDiffuse.rgb = max(0, lightIntensity);
    outDiffuse.a = 1.0f;

    outTexCood = inTexCood;
}

void PixelShader1(in float4 inScreenColor : COLOR0,
                  in float2 inTexCood     : TEXCOORD0,

                  out float4 outColor     : COLOR)
{
    float4 workColor = (float4)0;
    workColor = tex2D(textureSampler, inTexCood);
    outColor = inScreenColor * workColor;
}

technique Technique1
{
   pass Pass1
   {
      VertexShader = compile vs_3_0 VertexShader1();
      PixelShader = compile ps_3_0 PixelShader1();
   }
}
