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
    @Test("finds price in all price displays all prices", arguments: [
        AllPrice.Price.fake,
        AllPrice.Price.fake,
        AllPrice.Price.fake
    ])
    func testPrice(price: AllPrice.Price) throws {
        let dep = Dependency()
        let scheduler = TestScheduler(initialClock: 0)

        let expectedPrice = USDPrice(id: price.id, name: price.name, usd: price.price.usd, tags: price.tags)
        let item = AnyPricable(expectedPrice)

        dep.register(FeatureFlagProvider.self) { _ in
            MockFeatureFlagProvider()
        }

        dep.register(AllPriceUseCase.self) { _ in
            let mock = MockAllPriceUseCase()
            mock.stubbedFetchItemsResult = scheduler.createColdObservable([
                .next(5, [
                    AnyPricable(AllPrice.Price.fake),
                    AnyPricable(price),
                    AnyPricable(AllPrice.Price.fake)
                ])
            ]).asObservable()
            return mock
        }

        let sut = ItemDetailView.ViewModel(dependency: dep, item: item, scheduler: scheduler)

        scheduler.start()

        #expect(sut.price == "usd: \(price.price.usd)\neur: \(price.price.eur)")
        #expect(sut.title == price.name)
        #expect(sut.tags == price.tags.map { $0.rawValue } )
    }

    @MainActor
    @Test("shows warning label")
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
    @Test("hides warning label")
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
}

class MockFeatureFlagProvider: FeatureFlagProvider {

    var result: Bool?
    override func observeFlagValue(flag: FeatureFlagType) -> Observable<Bool> {
        flagsRelay.map { _ in
            self.result ?? false
        }
    }
}

extension TimeInterval {
    static var min: TimeInterval {
        5.0
    }
}

func awaitPublisher<T: Publisher>(
    _ publisher: T,
    timeout: TimeInterval = .min,
    file: StaticString = #file,
    line: UInt = #line
) async throws -> T.Output {
    // This time, we use Swift's Result type to keep track
    // of the result of our Combine pipeline:
    var result: Result<T.Output, Error>?
    var bag = Set<AnyCancellable>()

    try await confirmation() { confirmation in

        let value = try await publisher.awaitSink(cancellable: &bag)

        result = .success(value)

        confirmation()
    }

    bag = Set<AnyCancellable>()

    return try #require(result).get()
}

extension Publisher {
    func awaitSink(cancellable: inout Set<AnyCancellable>) async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            self
                .first() // Ensure we only take the first value
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        continuation.resume(with: .failure(error))
                    case .finished:
                        break
                    }
                } receiveValue: { result in
                    continuation.resume(with: .success(result))
                }
                .store(in: &cancellable)
        }
    }
}
