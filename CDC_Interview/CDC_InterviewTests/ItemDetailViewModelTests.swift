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
@testable import CDC_Interview


struct ItemDetailViewModelTests {

    @MainActor
    @Test("finds price in all price displays all prices", arguments: [
        AllPrice.Price.PriceRecord(usd: 1.0, eur: 3.0),
        AllPrice.Price.PriceRecord(usd: 4.6, eur: 10.2),
        AllPrice.Price.PriceRecord(usd: 88, eur: 89)
    ])
    func testPrice(price: AllPrice.Price.PriceRecord) throws {
        let dep = Dependency()
        let scheduler = TestScheduler(initialClock: 0)

        let expectedPrice = USDPrice(id: 1, name: "ABC", usd: price.usd, tags: [.deposit])
        let item = AnyPricable(expectedPrice)

        let allPrice = AllPrice.Price(id: 1, name: "ABC", price: .init(usd: price.usd, eur:
                                                                        price.eur), tags: [.deposit])
        dep.register(AllPriceUseCase.self) { _ in
            let mock = MockAllPriceUseCase()
            mock.stubbedFetchItemsResult = scheduler.createColdObservable([
                .next(5, [
                    AnyPricable(AllPrice.Price.fake),
                    AnyPricable(allPrice),
                    AnyPricable(AllPrice.Price.fake)
                ])
            ]).asObservable()
            return mock
        }

        let sut = ItemDetailView.ViewModel(dependency: dep, item: item, scheduler: scheduler)

        scheduler.start()

        #expect(sut.price == "usd: \(price.usd)\neur: \(price.eur)")
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
