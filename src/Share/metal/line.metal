#include <metal_stdlib>
using namespace metal;

kernel void lineEffect(texture2d<float, access::write> o [[texture(0)]],
                       constant float &time [[buffer(0)]],
                       constant float3 &color [[buffer(1)]],
                       ushort2 gid [[thread_position_in_grid]]) {
  float width = o.get_width();
  float height = o.get_height();

  if (width == 0 || height == 0) {
    o.write(float4(0, 0, 0, 0), gid);
    return;
  }

  float2 p = float2(gid) / float2(width, height);
  const float WHITE_HEIGHT = 10.0;
  const float COLOR_HEIGHT = 5.0;
  const float BLACK_HEIGHT = 10.0;

  float yDiff = abs(p.y - time * 8.0) * height; // 0.5 seconds/8.0
  if (yDiff < WHITE_HEIGHT) {
    float3 c = mix(float3(1.0, 1.0, 1.0), color, yDiff / WHITE_HEIGHT);
    o.write(float4(c, 1.0), gid); // white
  } else if (yDiff - WHITE_HEIGHT < COLOR_HEIGHT) {
    o.write(float4(color, 1.0), gid);
  } else if (yDiff - WHITE_HEIGHT - COLOR_HEIGHT < BLACK_HEIGHT) {
    float3 c = mix(color, float3(0.0, 0.0, 0.0), (yDiff - WHITE_HEIGHT - COLOR_HEIGHT) / BLACK_HEIGHT);
    o.write(float4(c, 1.0), gid); // white
  } else {
    o.write(float4(0, 0, 0, 0), gid);
  }
}
