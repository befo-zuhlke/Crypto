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

extension USDPrice {
    static var fake: USDPrice {
        USDPrice(
            id: faker.number.randomInt(),
            name: faker.lorem.word(),
            usd: Decimal(faker.number.randomDouble()),
            tags: .fake
        )
    }
}

extension AllPrice {
    static var fake: AllPrice {
        AllPrice(data: .fake)
    }
}

extension Price {
    static var fake: Price {
        Price(
            value: Decimal(faker.number.randomDouble()),
            currency: .fake
        )
    }
}

extension Tag {
    static var fake: Tag {
        Tag.allCases.randomElement() ?? .deposit
    }
}

extension Currency {
    static var fake: Currency {
        Currency.allCases.randomElement() ?? .usd
    }
}

extension AllPrice.Price {
    static var fake: AllPrice.Price {
        AllPrice.Price(
            id: faker.number.randomInt(),
            name: faker.lorem.word(),
            price: .fake,
            tags: .fake
        )
    }
}

extension AllPrice.Price.PriceRecord {
    static var fake: AllPrice.Price.PriceRecord {
        AllPrice.Price.PriceRecord(
            usd: Decimal(faker.number.randomDouble()),
            eur: Decimal(faker.number.randomDouble())
        )
    }
}

extension Sequence where Element == Tag {
    static var fake: [Tag] {
        (0..<Tag.allCases.count).map { _ in Tag.fake }
    }
}

extension Sequence where Element == AllPrice.Price {
    static var fake: [AllPrice.Price] {
        (0..<5).map { _ in .fake }
    }
}
