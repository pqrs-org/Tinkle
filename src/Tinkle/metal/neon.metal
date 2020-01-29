#include <metal_stdlib>
using namespace metal;

namespace{
    float line(float2 start, float2 end, float2 uv){
        float2 line = end - start;
        float frac = dot(uv - start, line) / dot(line, line);
        return distance(start + line * clamp(frac, 0.0, 1.0), uv);
    }
}

kernel void neonEffect(texture2d<float, access::write> o [[texture(0)]],
                       constant float &time [[buffer(0)]],
                       constant float3 &color [[buffer(1)]],
                       ushort2 gid [[thread_position_in_grid]]) {
    float width = o.get_width();
    float height = o.get_height();

    float2 uv = float2(gid) / float2(width, height);
    uv -= 0.5;

    float box = 1.0;
    // top
    box = min(box, line(float2(-0.49, 0.49), float2(0.49, 0.49), uv));
    // bottom
    box = min(box, line(float2(-0.49, -0.49), float2(0.49, -0.49), uv));
    // left
    box = min(box, line(float2(-0.49, -0.49), float2(-0.49, 0.49), uv));
    // right
    box = min(box, line(float2(0.49, -0.49), float2(0.49, 0.49), uv));

    float shade = 0.01 * (1.0 - time * 2.0) / max(0.0001, box - 0.0002);

    float3 c = color * shade;

    float alpha = min(max(max(c[0], c[1]), c[2]), 0.5 - time * 2.0);

    o.write(float4(c, alpha), gid);
}
