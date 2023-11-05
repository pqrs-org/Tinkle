#include <metal_stdlib>
using namespace metal;

kernel void nopEffect(texture2d<float, access::write> o [[texture(0)]],
                      constant float &time [[buffer(0)]],
                      constant float3 &color [[buffer(1)]],
                      ushort2 gid [[thread_position_in_grid]]) {
  o.write(float4(0, 0, 0, 0), gid);
}
