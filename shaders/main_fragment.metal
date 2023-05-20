#if CODE_GEN_HEADER || DUMMY
#include <metal_stdlib>
using namespace metal;

#include "shader_types.h"

#if DUMMY
#define testConstant 32
#endif
#endif

#if CODE_GEN_BODY || DUMMY
fragment void main_fragment(MainVertexOut in [[stage_in]],
                            device uint& mainBuffer [[buffer(0)]]) {
#if DEBUG
    mainBuffer = test_var;
#else
    mainBuffer = test_var + testConstant;
#endif
}
#endif
