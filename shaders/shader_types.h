#pragma once

#include <metal_stdlib>
using namespace metal;

#define test_var 1

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
