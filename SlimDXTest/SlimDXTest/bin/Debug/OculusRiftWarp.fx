sampler2D TexMap;
float2 LensCenter;
float2 ScreenCenter;
float2 Scale;
float2 ScaleIn;
float4 HmdWarpParam;

// Scales input texture coordinates for distortion.
// ScaleIn maps texture coordinates to Scales to ([-1, 1]), although top/bottom will be
// larger due to aspect ratio.
float2 HmdWarp(float2 in01)
{
   float2 theta = (in01 - LensCenter) * ScaleIn; // Scales to [-1, 1]
   float  rSq = theta.x * theta.x + theta.y * theta.y;
   float2 theta1 = theta * (HmdWarpParam.x + HmdWarpParam.y * rSq + 
                   HmdWarpParam.z * rSq * rSq + HmdWarpParam.w * rSq * rSq * rSq);
   return LensCenter + Scale * theta1;
}

float4 RiftWarp(float2 tc : TEXCOORD0) : COLOR
{
   float2 newtc = HmdWarp(tc);
   if (any(clamp(tc, ScreenCenter-float2(0.25,0.5), ScreenCenter+float2(0.25, 0.5)) - tc))
       return 0;
   return tex2D(TexMap, newtc);
};


technique ViewShader
{
    pass P0
    {
        VertexShader = null;
		PixelShader = compile ps_2_0 RiftWarp();
    }
}