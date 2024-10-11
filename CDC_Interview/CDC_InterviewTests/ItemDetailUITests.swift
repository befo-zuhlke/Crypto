//
//  Test.swift
//  CDC_InterviewTests
//
//  Created by Ben Fowler on 11/10/2024.
//

import SnapshotTesting
import XCTest
import SwiftUI
@testable import CDC_Interview

class ItemDetailTests: XCTestCase {

  func testUSDPrice() {
      let price = USDPrice(
        id: 1,
        name: "Expensive coin",
        usd: 1123.123123,
        tags: [.deposit]
      )

      let vc = UINavigationController(
        rootViewController: UIHostingController(
            rootView: ItemDetailView(item: AnyPricable(price))
        )
      )

      assertSnapshot(of: vc, as: .image)
  }

    func testAllPrice() {
        let price = AllPrice.Price(
            id: 2,
            name: "GGG",
            price: .init(usd: 123.123, eur: 123.123),
            tags:  [.withdrawal]
        )

        let vc = UINavigationController(
          rootViewController: UIHostingController(
              rootView: ItemDetailView(item: AnyPricable(price))
          )
        )

        assertSnapshot(of: vc, as: .image)
    }

}
