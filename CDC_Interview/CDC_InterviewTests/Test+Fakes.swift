//
//  Test+Fakes.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 9/10/2024.
//

import Fakery
import XCTest
@testable import CDC_Interview

let faker = Faker()

extension InstrumentPriceCell.ViewModel {
    static var fake: InstrumentPriceCell.ViewModel {
        let x = InstrumentPriceCell.ViewModel()
        x.usdPrice = .init(
            id: faker.number.randomInt(),
            name: faker.lorem.word(),
            usd: Decimal(faker.number.randomDouble()),
            tags: [.deposit]
        )
        return x
    }
}
