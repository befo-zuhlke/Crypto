//
//  USDUseCaseTests.swift
//  CDC_InterviewTests
//
//  Created by Ben Fowler on 11/10/2024.
//

import XCTest
import RxTest
import RxSwift
@testable import CDC_Interview

final class USDUseCaseTests: XCTestCase {

    func testUseCase() throws {
        let scheduler = TestScheduler(initialClock: 0)
        let bag = DisposeBag()
        let sut = USDPriceUseCase()

        let observer = scheduler.createObserver([AnyPricable].self)

        sut.fetchItems(scheduler: scheduler).bind(to: observer).disposed(by: bag)

        scheduler.start()

        let expected = [
            USDPrice(
              id: 1,
              name: "BTC",
              usd: 125.41487692,
              tags: [
                .withdrawal,
                .deposit
              ]
            ),
            USDPrice(
              id: 2,
              name: "ETH",
              usd: 2939.10616566,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 3,
              name: "SOL",
              usd: 995.86519389,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 4,
              name: "CRO",
              usd: 83.31980303,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 5,
              name: "FIL",
              usd: 1262.67218869,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 6,
              name: "MATIC",
              usd: 2593.72882139,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 7,
              name: "ETH",
              usd: 2835.76632594,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 8,
              name: "AAVE",
              usd: 495.3154702,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 9,
              name: "ACA",
              usd: 636.21312753,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 10,
              name: "BCH",
              usd: 344.9964878,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 11,
              name: "BNT",
              usd: 1673.38604708,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 12,
              name: "CHZ",
              usd: 214.23713525,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 13,
              name: "DAI",
              usd: 2790.90464506,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 14,
              name: "ENA",
              usd: 1073.08992265,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 15,
              name: "ENS",
              usd: 2614.13186028,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 16,
              name: "KLAY",
              usd: 117.00936124,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 17,
              name: "PYUSD",
              usd: 1872.15615071,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 18,
              name: "ZRX",
              usd: 2004.43042267,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 19,
              name: "MDT",
              usd: 63.94278742,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 20,
              name: "YFF",
              usd: 863.23012886,
              tags: [
                .deposit
              ]
            ),
            USDPrice(
              id: 21,
              name: "VET",
              usd: 1768.14368212,
              tags: [
                .deposit
              ]
            )
        ]

        XCTAssertEqual(observer.events.dropLast(), [.next(2, expected.map(AnyPricable.init))])
    }
}
