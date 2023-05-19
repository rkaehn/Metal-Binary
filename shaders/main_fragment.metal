#include <metal_stdlib>
using namespace metal;

#include "shader_types.h"

#if DUMMY
constant uchar testConstant [[function_constant(0)]];
#endif

fragment void main_fragment(MainVertexOut in [[stage_in]],
                            device uint& mainBuffer [[buffer(0)]]) {
#if DEBUG
    mainBuffer = test_var;
#else
    mainBuffer = test_var + testConstant;
#endif
}
