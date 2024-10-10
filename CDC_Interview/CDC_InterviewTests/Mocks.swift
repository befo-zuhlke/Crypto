//
//  Mocks.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 10/10/2024.
//

import RxSwift
@testable import CDC_Interview

class MockNavigator: Navigating {

    var callCount = 0
    var toDetailViewArgs: AnyPricable?
    func toDetailView(price: AnyPricable) {
        callCount += 1
        toDetailViewArgs = price
    }
}

class MockUSDPriceUseCase: USDPriceUseCase {
    var stubbedFetchItemsResult: Observable<[AnyPricable]>!
    override func fetchItems() -> Observable<[AnyPricable]> {
        return stubbedFetchItemsResult
    }
}

class MockAllPriceUseCase: AllPriceUseCase {
    var stubbedFetchItemsResult: Observable<[AnyPricable]>!
    override func fetchItems() -> Observable<[AnyPricable]> {
        return stubbedFetchItemsResult
    }
}

class MockFetcher: Fetching {

    var items: [AnyPricable]
    var fetchItemsCallCount = 0
    var searchTerm: String?

    init(items: [AnyPricable]) {
        self.items = items
    }

    func fetchItems(searchText: String?) -> Observable<[AnyPricable]> {
        searchTerm = searchText
        fetchItemsCallCount += 1
        return Single<[AnyPricable]>.create { [unowned self] in
            $0(.success(items))
            return Disposables.create {}
        }
        .asObservable()
    }
}

class MockFeatureFlagProvider: FeatureFlagProvider {

    var result: Bool?
    override func observeFlagValue(flag: FeatureFlagType) -> Observable<Bool> {
        flagsRelay.map { _ in
            self.result ?? false
        }
    }
}
