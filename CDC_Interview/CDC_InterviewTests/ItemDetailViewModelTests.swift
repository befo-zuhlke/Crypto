//
//  ItemDetailViewModelTests.swift
//  CDC_InterviewTests
//
//  Created by Ben Fowler on 9/10/2024.
//

import Testing
import Combine
import Foundation
import RxTest
import RxSwift
@testable import CDC_Interview


struct ItemDetailViewModelTests {

    @MainActor
    @Test("format's output from item", arguments: [
        AllPrice.Price.fake,
        AllPrice.Price.fake,
        AllPrice.Price.fake
    ])
    func testPrice(price: AllPrice.Price) throws {
        let dep = Dependency()
        let scheduler = TestScheduler(initialClock: 0)

        let item = AnyPricable(price)

        dep.register(FeatureFlagProvider.self) { _ in
            let mock = MockFeatureFlagProvider()
            mock.result = true
            return mock
        }
        
        let sut = ItemDetailView.ViewModel(dependency: dep, item: item, scheduler: scheduler)

        scheduler.start()

        #expect(sut.price == "usd: \(price.price.usd)\neur: \(price.price.eur)")
        #expect(sut.title == price.name)
        #expect(sut.tags == price.tags.map { $0.rawValue } )
    }

    @MainActor
    @Test("shows warning label when not latest price")
    func testWarning() throws {
        let dep = Dependency()
        let scheduler = TestScheduler(initialClock: 0)

        let expectedPrice = USDPrice.fake
        let item = AnyPricable(expectedPrice)

        dep.register(FeatureFlagProvider.self) { _ in
            let mock = MockFeatureFlagProvider()
            mock.result = true
            return mock
        }

        dep.register(AllPriceUseCase.self) { _ in
            let mock = MockAllPriceUseCase()
            mock.stubbedFetchItemsResult = scheduler.createColdObservable([
                .next(5, [
                    AnyPricable(expectedPrice)
                ])
            ]).asObservable()
            return mock
        }

        let sut = ItemDetailView.ViewModel(dependency: dep, item: item, scheduler: scheduler)

        scheduler.start()

        #expect(sut.warning == "EUR is supported, please select item from list view again")
    }

    @MainActor
    @Test("hides warning label when v1 api being used")
    func hidesWarning() throws {
        let dep = Dependency()
        let scheduler = TestScheduler(initialClock: 0)

        let expectedPrice = USDPrice.fake
        let item = AnyPricable(expectedPrice)

        dep.register(FeatureFlagProvider.self) { _ in
            let mock = MockFeatureFlagProvider()
            mock.result = false
            return mock
        }

        dep.register(AllPriceUseCase.self) { _ in
            let mock = MockAllPriceUseCase()
            mock.stubbedFetchItemsResult = scheduler.createColdObservable([
                .next(5, [
                    AnyPricable(expectedPrice)
                ])
            ]).asObservable()
            return mock
        }

        let sut = ItemDetailView.ViewModel(dependency: dep, item: item, scheduler: scheduler)

        scheduler.start()

        #expect(sut.warning == "")
    }

    @MainActor
    @Test("hides warning label when v2 api being used")
    func hidesWarningOnV2Api() throws {
        let dep = Dependency()
        let scheduler = TestScheduler(initialClock: 0)

        let expectedPrice = AllPrice.Price.fake
        let item = AnyPricable(expectedPrice)

        dep.register(FeatureFlagProvider.self) { _ in
            let mock = MockFeatureFlagProvider()
            mock.result = true
            return mock
        }

        dep.register(AllPriceUseCase.self) { _ in
            let mock = MockAllPriceUseCase()
            mock.stubbedFetchItemsResult = scheduler.createColdObservable([
                .next(5, [
                    AnyPricable(expectedPrice)
                ])
            ]).asObservable()
            return mock
        }

        let sut = ItemDetailView.ViewModel(dependency: dep, item: item, scheduler: scheduler)

        scheduler.start()

        #expect(sut.warning == "")
    }
}
