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

extension Tag {
    static var fake: Tag {
        Tag.allCases.randomElement() ?? .deposit
    }
}

extension Sequence where Element == Tag {
    static var fake: [Tag] {
        (0..<Tag.allCases.count).map { _ in Tag.fake }
    }
}
