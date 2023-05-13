Introduction:

My app (TestFlight: https://plastic.app) requires a large number of shaders, specifically many permutations of one shader, to provide optimal runtime performance for the user. Compiling all these permutations on the device would increase app launch time significantly. As such, I want to ship binary versions of all permutations with the app. 

Additionally, I want different behavior in Debug vs Release mode:
- Debug: Compile one shader that uses function arguments to change its behavior instead of function constants (fast build times, lower runtime performance)
- Release: Compile all relevant permutations using function constants (long build times, higher runtime performance)

This last part is not really important to the topic of this support request, but explains why this sample is structured the way it is.

Problem:
- With Xcode 14.2 and targeting an iPhone XS Max running iOS 16.2, both Debug (no function specialization) and Release (function specialization) print the correct result (Debug: "1", Release: "17")
- With Xcode 14.2 and targeting an iPhone 14 Pro Max running iOS 16.3.1, Debug works, Release fails on MTLRenderPipelineState creation with the error "Failed to find precompiled function 'main_fragment_0' in binary archives"
- With Xcode 14.3 and targeting the iPhone XS Max running iOS 16.2, Debug works, Release fails with that same error
- With Xcode 14.3 and targeting the iPhone 14 Pro Max running iOS 16.3.1, Debug and Release work

I am suspecting that I am making some kind of mistake while building the binary slices of my Metal libraries, but I am not sure where. I have tried providing minimum platform requirements of iOS 16 to metal and metal-tt in various configurations, but the error persisted. Is it possible that something changed in the way specialized functions are defined in mtlp-json between the toolchains in Xcode 14.2 and 14.3? 
I have also tried having the Debug configuration create the specialized function to verify the issues are not related to any other settings affected by Debug/Release. It is always the configuration that creates a specialized function that fails.

Structure of the project:
- "shaders" target:
    - Produces "shaders.framework"
    - Public interface defined in "PipelineStateCache.swift" and "PipelineStateRecipe.swift"
    - Provides a minimal abstraction over an instance of a MTLBinaryArchive. Usage:
        1. Define a PipelineStateRecipe in the "PipelineStateRecipe" enum (e.g. ".main")
        2. Define a method to create PipelineStateDescriptors (e.g. "mainDebugExecute" and "mainReleaseExecute")
        3. At runtime, use these PipelineStateDescriptors to retrieve MTLRenderPipelineStates from the PipelineStateCache
    - (All of this has already been prepared in this sample project.)
- "shaders-test-ios" and "shaders-test-macos" targets:
    - Sample apps that use "shaders.framework"

Details:
- The "main.metallib" (containing air64 slice) and "mainbin.metallib" (containing binary slices) are created in the "Build Metallibs" build phase of the "shaders" target using make. "make_shaders" defines recipes to...:
    1. Build "main.air" from "main.metal"
    2. Create "main.metallib" from "main.air"
    3. Create the pipeline script "main.mtlp-json" using "mtlp-json.swift"
    4. Build "mainbin.metallib" from "main.metallib" and "main.mtlp-json"
- The make log and the contents of main.mtlp-json can easily be seen in the build log
