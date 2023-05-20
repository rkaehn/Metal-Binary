// CODE_GEN_HEADER_BEGIN
#include <metal_stdlib>
using namespace metal;

#include "shader_types.h"

#if DUMMY
#define testConstant 32
#endif
// CODE_GEN_HEADER_END

// CODE_GEN_BODY_BEGIN
fragment void main_fragment(MainVertexOut in [[stage_in]],
                            device uint& mainBuffer [[buffer(0)]]) {
#if DEBUG
    mainBuffer = test_var;
#else
    mainBuffer = test_var + testConstant;
#endif
}
// CODE_GEN_BODY_END
