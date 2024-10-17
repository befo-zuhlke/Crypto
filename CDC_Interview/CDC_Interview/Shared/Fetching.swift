//
//  Fetching.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 9/10/2024.
//

import RxSwift

protocol Fetching {
    func fetchItems(searchText: String?) -> Observable<[AnyPricable]>
}

class ItemPriceFetcher: Fetching {

    private let usdUseCase: USDPriceUseCase
    private let allUseCase: AllPriceUseCase
    private let featureFlagProvider: FeatureFlagProvider

    init(dependency: Dependency = Dependency.shared) {
        self.usdUseCase = dependency.resolve(USDPriceUseCase.self)!
        allUseCase = dependency.resolve(AllPriceUseCase.self)!
        self.featureFlagProvider = dependency.resolve(FeatureFlagProvider.self)!
    }

    func fetchItems(searchText: String?) -> Observable<[AnyPricable]> {

        let search = Self.filterSearch(searchText: searchText)

        let v1 = featureFlagProvider.observeFlagValue(flag: .supportEUR)
            .filter { $0 == false }
            .flatMapLatest { _ in
                self.usdUseCase.fetchItems()
            }

        let v2 = featureFlagProvider.observeFlagValue(flag: .supportEUR)
            .filter { $0 == true }
            .flatMapLatest { _ in
                self.allUseCase.fetchItems()
            }

        return v1.amb(v2).map(search)
     }

     static func filterSearch(searchText: String?) -> (_: [AnyPricable]) -> [AnyPricable] {
         { items in
             items.filter {
                 guard let searchText = searchText, !searchText.isEmpty else {
                     return true
                 }

                 return $0.name.lowercased().contains(searchText.lowercased())
             }
         }
     }
}
