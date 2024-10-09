
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let features = FeatureFlagProvider()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Dependency.shared.register(USDPriceUseCase.self) { resolver in
            return USDPriceUseCase()
        }
        
        Dependency.shared.register(AllPriceUseCase.self) { resolver in
            return AllPriceUseCase()
        }
        
        Dependency.shared.register(FeatureFlagProvider.self) { [unowned self] resolver in
            return features
        }

        Dependency.shared.register(Fetching.self) { resolver in
            return ItemPriceFetcher()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

