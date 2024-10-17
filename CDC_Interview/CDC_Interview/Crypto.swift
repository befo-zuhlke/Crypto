import SwiftUI

@main
struct Crypto: App {

    private var featureFlags = FeatureFlagProvider()
    
    init() {
        registerDependencies()
    }

    private func registerDependencies() {

        Dependency.shared.register(USDPriceUseCase.self) { _ in
            USDPriceUseCase()
        }

        Dependency.shared.register(AllPriceUseCase.self) { _ in
            AllPriceUseCase()
        }

        Dependency.shared.register(FeatureFlagProvider.self) { _ in
            featureFlags
        }

        Dependency.shared.register(Fetching.self) { resolver in
            ItemPriceFetcher()
        }
    }

    var body: some Scene {
        WindowGroup {
            LandingView()
        }
    }
}
