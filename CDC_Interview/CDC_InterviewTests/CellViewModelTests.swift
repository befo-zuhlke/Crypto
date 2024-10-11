//
//  CellViewModelTests.swift
//  CDC_InterviewTests
//
//  Created by Ben Fowler on 11/10/2024.
//

import Testing
@testable import CDC_Interview
import RxTest

struct CellViewModelTests {

    @MainActor
    @Test("cell initial config")
    func cellInitialConfiguration() async throws {
        let scheduler = TestScheduler(initialClock: 0)
        let sut = InstrumentPriceCell.ViewModel()

        #expect(sut.title == "")
        #expect(sut.description == "")
        #expect(sut.backgroundColor == .lightGray)
        #expect(sut.hasViewed == false)
    }

    @MainActor
    @Test(
        "Cell is set from price",
        arguments: [
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake),
        ]
    )
    func cellIsConfigured(price: AnyPricable) async throws {
        let scheduler = TestScheduler(initialClock: 0)
        let sut = InstrumentPriceCell.ViewModel(scheduler: scheduler)

        sut.price = price

        scheduler.start()

        #expect(sut.title == price.name)
        #expect(sut.description == "\(price.prices.first { $0.currency == .usd }!.value)")
        #expect(sut.backgroundColor == .white)
        #expect(sut.hasViewed == true)
    }

}
