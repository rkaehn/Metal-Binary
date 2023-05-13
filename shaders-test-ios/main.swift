import UIKit
import shaders

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = MTLCreateSystemDefaultDevice()!
        let commandQueue = device.makeCommandQueue()!
        
        let mainBuffer = device.makeBuffer(length: 4, options: .storageModeShared)!
        
        let cache = PipelineStateCache(device: device)
        var rps: MTLRenderPipelineState!
        withPipelineStateDescriptor(recipe: .main) {
            rps = cache.makePipelineStateWithDescriptor($0)
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.renderTargetWidth = 1
        passDescriptor.renderTargetHeight = 1
        passDescriptor.defaultRasterSampleCount = 1
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)!
        commandEncoder.setFragmentBuffer(mainBuffer, offset: 0, index: 0)
        commandEncoder.setRenderPipelineState(rps)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let value = mainBuffer.contents().load(as: UInt32.self)
        print(value)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.frame = windowScene.coordinateSpace.bounds
        
        let viewController = ViewController()
        window.rootViewController = viewController
        
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    NSStringFromClass(UIApplication.self),
    NSStringFromClass(AppDelegate.self))
