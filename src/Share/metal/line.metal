#include <metal_stdlib>
using namespace metal;

kernel void lineEffect(texture2d<float, access::write> o [[texture(0)]],
                       constant float &time [[buffer(0)]],
                       constant float3 &color [[buffer(1)]],
                       ushort2 gid [[thread_position_in_grid]]) {
  float width = o.get_width();
  float height = o.get_height();

  float3 c = color;
  float shade = 0.0;
  if (height > 0) {
    float2 p = float2(gid) / float2(width, height);

    float s = abs(p.y - time * 8.0); // 0.5 seconds/8.0
    if (s < 2.0 / height) {          // 2 pixel
      shade = 1.0;
      c = 1.0;                     // white
    } else if (s < 6.0 / height) { // 4 pixel
      shade = 1.0;
    } else if (s < 7.0 / height) { // 1 pixel
      shade = 1.0;
      c = 0.0; // black
    }
  }

  float alpha = shade;

  o.write(float4(c, alpha), gid);
}
