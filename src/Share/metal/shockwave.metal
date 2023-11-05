#include <metal_stdlib>
using namespace metal;

namespace {
float circle(float2 uv, float r, float blur) {
  float d = length(uv);
  float c = smoothstep(r, r - blur, d);
  return c;
}
} // namespace

kernel void shockwaveEffect(texture2d<float, access::write> o [[texture(0)]],
                            constant float &time [[buffer(0)]],
                            constant float3 &color [[buffer(1)]],
                            ushort2 gid [[thread_position_in_grid]]) {
  float width = o.get_width();
  float height = o.get_height();

  float2 p = float2(gid) / float2(width, height);
  p -= 0.5;
  p.x *= min(width / height, 1.0);
  p.y *= min(height / width, 1.0);

  float speed = 4.0;
  float r = time * speed + 0.6;
  float ir = clamp(1.0 - speed * time, 0.9, 1.0);

  float c1 = circle(p, r, 0.4);
  float c2 = circle(p, r, ir);
  float shade = c1 - c2;
  float3 c = color * shade;

  float alpha = min(shade, 0.5);
  // float alpha = min(max(max(c[0], c[1]), c[2]), 0.5);

  o.write(float4(c, alpha), gid);
}
