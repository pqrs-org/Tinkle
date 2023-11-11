#include <metal_stdlib>
using namespace metal;

kernel void neonEffect(texture2d<float, access::write> o [[texture(0)]],
                       constant float &time [[buffer(0)]],
                       constant float3 &color [[buffer(1)]],
                       ushort2 gid [[thread_position_in_grid]]) {
  const float PI = 3.14159265359;
  const float EFFECT_WIDTH = 80; // The width of the neon effect (pixel)

  float width = o.get_width();
  float height = o.get_height();
  float edgeWidth = width > 0 ? EFFECT_WIDTH / width : 0;

  // Convert gid to normalized texture coordinates
  float2 uv = float2(gid) / float2(width, height);

  // Calculate distance to the nearest edge
  float distToEdge = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));

  // The intensity of the neon effect
  float intensity = smoothstep(edgeWidth, 0.0, distToEdge);

  // Modulate the intensity with time for a pulsing effect
  intensity *= sin(time * 4.0 * PI) * 0.5 + 0.5;

  // Calculate the final color
  float3 finalColor = mix(float3(0.0, 0.0, 0.0), color, intensity);
  // Transparent after 300ms.
  float alpha = time < 0.3 ? intensity : 0.0;

  // Write the color to the output texture
  o.write(float4(finalColor, alpha), gid);
}
