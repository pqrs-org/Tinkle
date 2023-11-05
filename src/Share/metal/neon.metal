#include <metal_stdlib>
using namespace metal;

kernel void neonEffect(texture2d<float, access::write> o[[texture(0)]],
                       constant float &time[[buffer(0)]],
                       constant float3 &color[[buffer(1)]],
                       ushort2 gid[[thread_position_in_grid]])
{
    float width = o.get_width();
    float height = o.get_height();

    float2 uv = float2(gid) / float2(width, height);
    uv -= 0.5;

    float box = 1.0;
    box = min(box, smoothstep(1.0, 0.0, abs(uv[0]) * 2));
    box = min(box, smoothstep(1.0, 0.0, abs(uv[1]) * 2));

    float shade = 0.005 * max(0.0, 1.0 - time * 5.0) / max(0.0005, box - 0.001);
    //    float shade = box;

    float3 c = color * shade;

    float alpha = min(shade, 0.5 - time * 2.0);
    // float alpha = min(max(max(c[0], c[1]), c[2]), 0.5 - time * 2.0);


    o.write(float4(c, alpha), gid);
}
