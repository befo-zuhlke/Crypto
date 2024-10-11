import XCTest
import RxTest
import RxSwift
@testable import CDC_Interview

final class AllPriceUseCaseTests: XCTestCase {

    func testUseCase() throws {
        let scheduler = TestScheduler(initialClock: 0)
        let bag = DisposeBag()
        let sut = AllPriceUseCase()

        let observer = scheduler.createObserver([AnyPricable].self)

        sut.fetchItems(scheduler: scheduler).bind(to: observer).disposed(by: bag)

        scheduler.start()

        let expected = [
            AllPrice.Price(
                id: 1,
                name: "BTC",
                price: .init(usd: 150.12345678, eur: 135.12345678),
                tags: [.withdrawal, .deposit]
            ),
            AllPrice.Price(
                id: 2,
                name: "ETH",
                price: .init(
                    usd: 150.12345678,
                    eur: 135.12345678
                ),
                tags: [.deposit]
            ),
            AllPrice.Price(
                id: 3,
                name: "SOL",
                price: .init(
                    usd: 150.12345678,
                    eur: 135.12345678
                ),
                tags: [.deposit]
            )
        ]

        XCTAssertEqual(observer.events.dropLast(), [.next(2, expected.map(AnyPricable.init))])
    }
}
