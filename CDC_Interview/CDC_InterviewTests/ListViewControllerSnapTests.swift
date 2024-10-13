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
    func testList() async throws {
        let scheduler = TestScheduler(initialClock: 0)

        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "usdPrices", ofType: "json")!
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let items = try JSONDecoder().decode([USDPrice].self, from: data).map(AnyPricable.init)

        // Register the dependency before creating the view controller
        Dependency.shared.register(Fetching.self) { _ in
            MockFetcher(items: items)
        }

        // Create the view controller after registering dependencies
        let vc = UINavigationController(rootViewController: ListViewController())

        vc.view.layoutIfNeeded()

        // Start the scheduler
        scheduler.start()

        // Allow the UI to layout
        try await Task.sleep(for: .seconds(4.0))

        assertSnapshot(of: vc, as: .image)
    }
}
