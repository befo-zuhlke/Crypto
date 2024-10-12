//
//  ListViewControllerSnapTests.swift
//  CDC_InterviewTests
//
//  Created by Ben Fowler on 11/10/2024.
//

import XCTest
import SnapshotTesting
import RxTest
import RxSwift
@testable import CDC_Interview

final class ListViewControllerSnapTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testList() throws {
        let scheduler = TestScheduler(initialClock: 0)

        let vc = UINavigationController(rootViewController: ListViewController())
        Dependency.shared.register(Fetching.self) { _ in
            MockFetcher(items: [
                USDPrice.fake,
                USDPrice.fake,
                USDPrice.fake,
                USDPrice.fake,
                USDPrice.fake
            ].map(AnyPricable.init))
        }
        scheduler.start()

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 3.5))


        assertSnapshot(of: vc, as: .image)
    }
}
