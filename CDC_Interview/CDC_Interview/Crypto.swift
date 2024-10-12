//
//  CryptoApp.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 12/10/2024.
//

import SwiftUI

@main
struct Crypto: App {

    init() {
        Dependency.shared.register(USDPriceUseCase.self) { resolver in
            return USDPriceUseCase()
        }

        Dependency.shared.register(AllPriceUseCase.self) { resolver in
            return AllPriceUseCase()
        }

        Dependency.shared.register(FeatureFlagProvider.self) { resolver in
            return FeatureFlagProvider()
        }

        Dependency.shared.register(Fetching.self) { resolver in
            return ItemPriceFetcher()
        }
    }
    var body: some Scene {
        WindowGroup {
            LandingView()
        }
    }
}
