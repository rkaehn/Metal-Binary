#include <metal_stdlib>
using namespace metal;

constant uchar testConstant [[function_constant(0)]];

constant float2 quad_pos[] = {
    float2(-1, -1),
    float2(-1,  1),
    float2( 1,  1),
    float2(-1, -1),
    float2( 1,  1),
    float2( 1, -1)
};

struct MainVertexOut {
    float4 position [[position]];
};

vertex MainVertexOut main_vertex(uint vid [[vertex_id]]) {
    MainVertexOut out;
    out.position = float4(quad_pos[vid], 0, 1);
    return out;
}

fragment void main_fragment(MainVertexOut in [[stage_in]],
                            device uint& mainBuffer [[buffer(0)]]) {
#if DEBUG
    mainBuffer = 1;
#else
    mainBuffer = 1 + testConstant;
#endif
}
