#include <metal_stdlib>
using namespace metal;

#include "shader_types.h"

vertex MainVertexOut main_vertex(uint vid [[vertex_id]]) {
    MainVertexOut out;
    out.position = float4(quad_pos[vid], 0, 1);
    return out;
}
