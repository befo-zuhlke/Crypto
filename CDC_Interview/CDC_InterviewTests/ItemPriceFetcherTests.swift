//
//  PriceFetcherTests.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 17/10/2024.
//

import Testing
import Fakery
import RxTest
import RxSwift
@testable import CDC_Interview

struct PriceFetcherTests {

    let faker = Faker()

    @MainActor
    @Test("filterSearch returns all items when searchText is nil")
    func testFilterSearch() {

        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let items = [AnyPricable(USDPrice.fake), AnyPricable(USDPrice.fake)]

        let dep = Dependency.shared

        dep.register(USDPriceUseCase.self) { _ in
            let mock  = MockUSDPriceUseCase()
            mock.stubbedFetchItemsResult = .just(items).asObservable()
            return mock
        }

        dep.register(AllPriceUseCase.self) { _ in
            let mock  = MockAllPriceUseCase()
            mock.stubbedFetchItemsResult = .just(items).asObservable()
            return mock
        }

        dep.register(FeatureFlagProvider.self) { _ in
            return MockFeatureFlagProvider()
        }


        let sut = ItemPriceFetcher(dependency: dep)
        let observer = scheduler.createObserver([AnyPricable].self)
        sut.fetchItems(searchText: nil).bind(to: observer).disposed(by: bag)

        scheduler.start()

        #expect(observer.events == [.next(0, items)])
    }

    @MainActor
    @Test("filterSearch returns matches by name", arguments: [0,1,2])
    func testFilterSearchMatchesByName(indexToSearch: Int) async throws {

        let bag = DisposeBag()

        let scheduler = TestScheduler(initialClock: 0)

        let items = [
            AnyPricable(USDPrice(id: 0, name: "ABC", usd: 0.0, tags: [])),
            AnyPricable(USDPrice(id: 0, name: "123", usd: 0.0, tags: [])),
            AnyPricable(USDPrice(id: 0, name: "TESTING", usd: 0.0, tags: [])),
        ]
        
        let nameToSearch = items[indexToSearch].name

        let dep = Dependency.shared

        dep.register(USDPriceUseCase.self) { _ in
            let mock  = MockUSDPriceUseCase()
            mock.stubbedFetchItemsResult = .just(items).asObservable()
            return mock
        }

        dep.register(AllPriceUseCase.self) { _ in
            let mock  = MockAllPriceUseCase()
            mock.stubbedFetchItemsResult = .just(items).asObservable()
            return mock
        }

        dep.register(FeatureFlagProvider.self) { _ in
            return MockFeatureFlagProvider()
        }

        let sut = ItemPriceFetcher(dependency: dep)

        let observer = scheduler.createObserver([AnyPricable].self)
        sut.fetchItems(searchText: nameToSearch).bind(to: observer).disposed(by: bag)

        scheduler.start()

        #expect(observer.events == [.next(0, [items[indexToSearch]])])

    }

}
