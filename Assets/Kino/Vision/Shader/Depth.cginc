//
// Kino/Vision - Frame visualization utility
//
// Copyright (C) 2016 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#include "UnityCG.cginc"

sampler2D _MainTex;
half _Opacity;
half _Repeat;

sampler2D_float _CameraDepthTexture;
sampler2D _CameraDepthNormalsTexture;

float3 Hue(float h)
{
    float r = abs(h * 6 - 3) - 1;
    float g = 2 - abs(h * 6 - 2);
    float b = 2 - abs(h * 6 - 4);
    return saturate(float3(r, g, b));
}

half4 frag_depth(v2f_img i) : SV_Target
{
    half4 src = tex2D(_MainTex, i.uv);

#ifdef USE_CAMERA_DEPTH
    float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
    depth = Linear01Depth(depth);
    depth = 1 - depth;
#else // USE_CAMERA_DEPTH_NORMALS
    float4 cdn = tex2D(_CameraDepthNormalsTexture, i.uv);
    float depth = DecodeFloatRG(cdn.zw) * _ProjectionParams.x;
#endif

#ifdef VISUALIZE_BLACK_WHITE
    half3 rgb = frac(depth * _Repeat);
#else // VISUALIZE_HUE
    half3 rgb = Hue(frac(depth * _Repeat));
#endif

#if !UNITY_COLORSPACE_GAMMA
    rgb = GammaToLinearSpace(rgb);
#endif

    rgb = lerp(src.rgb, rgb, _Opacity);

    return half4(rgb, src.a);
}
