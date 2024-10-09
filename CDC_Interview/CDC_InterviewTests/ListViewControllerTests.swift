
import XCTest
import RxTest
import RxSwift
@testable import CDC_Interview

final class ListViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetch() throws {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let dep = Dependency()

        dep.register(AllPriceUseCase.self) { _ in
            let mock = MockAllPriceUseCase()
            mock.stubbedFetchItemsResult = scheduler.createColdObservable(([
                .next(0, AllPrice.Price(id: 0, name: "", price: .init(usd: 0.0, eur: 0), tags: []))
            ])).asObservable()

            return mock
        }
        
        dep.register(USDPriceUseCase.self) { _ in
            let mock = MockUSDPriceUseCase()
            mock.stubbedFetchItemsResult = scheduler.createColdObservable([
                .next(0, []),
                .next(10, [USDPrice.init(id: 1, name: "a", usd: 1, tags: [.deposit])])
            ]).asObservable()
            
            return mock
        }
        
        dep.register(FeatureFlagProvider.self) { _ in
            let provider = FeatureFlagProvider()
            provider.update(flag: .supportEUR, newValue: false)
            return provider
        }
        
        let vc = ListViewController(dependency: dep)

        let itemsObserver = scheduler.createObserver([InstrumentPriceCell.ViewModel].self)
        vc.itemsObservable.distinctUntilChanged().bind(to: itemsObserver).disposed(by: disposeBag)
        vc.fetchItems(searchText: nil).subscribe().disposed(by: disposeBag)

        scheduler.start()

        let x = itemsObserver.events
            .map {
                Recorded(time: $0.time, value: $0.value.map {
                    val in val.map { x in x.prices }
                })
            }

        XCTAssertEqual(x, [
            .next(0, []),
            .next(10, [USDPrice.init(id: 1, name: "a", usd: 1, tags: [.deposit])]),
        ])
    }

    func testSearchCallsFetchItems() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let dep = Dependency()

        let expectedItems: [InstrumentPriceCell.ViewModel] = [
            .fake,
            .fake,
            .fake
        ]

        let mock = MockFetcher(items: expectedItems)
        dep.register(Fetching.self) { _ in
            mock
        }

        let sut = ListViewController.ViewModel(dependency: dep)
        let itemsObserver = scheduler.createObserver([InstrumentPriceCell.ViewModel].self)
        sut.items.bind(to: itemsObserver).disposed(by: bag)

        sut.searchTerm.accept("a")

        XCTAssertEqual(mock.fetchItemsCallCount, 1)
        XCTAssertEqual(itemsObserver.events.dropFirst(), [.next(0, expectedItems)])
    }
}

class MockUSDPriceUseCase: USDPriceUseCase {
    var stubbedFetchItemsResult: Observable<[USDPrice]>!
    override func fetchItems() -> Observable<[USDPrice]> {
        return stubbedFetchItemsResult
    }
}

class MockAllPriceUseCase: AllPriceUseCase {
    var stubbedFetchItemsResult: Observable<AllPrice.Price>!
    override func fetchItems() -> Observable<AllPrice.Price> {
        return stubbedFetchItemsResult
    }
}

class MockFetcher: Fetching {

    var items: [InstrumentPriceCell.ViewModel]
    var fetchItemsCallCount = 0

    init(items: [InstrumentPriceCell.ViewModel]) {
        self.items = items
    }

    func fetchItems(searchText: String?) -> Observable<[InstrumentPriceCell.ViewModel]> {
        fetchItemsCallCount += 1
        return Single<[InstrumentPriceCell.ViewModel]>.create { [unowned self] in
            $0(.success(items))
            return Disposables.create {}
        }
        .asObservable()
    }
}


