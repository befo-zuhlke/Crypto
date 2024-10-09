
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

    func testFetchItemsOnInit() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let dep = Dependency()

        let expectedItems: [AnyPricable] = [
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake)
        ]

        let mock = MockFetcher(items: expectedItems)
        dep.register(Fetching.self) { _ in
            mock
        }

        let sut = ListViewController.ViewModel(dependency: dep, scheduler: scheduler)
        let itemsObserver = scheduler.createObserver([AnyPricable].self)
        sut.items.bind(to: itemsObserver).disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(mock.fetchItemsCallCount, 1)
        XCTAssertEqual(mock.searchTerm, nil)
        XCTAssertEqual(itemsObserver.events.dropFirst(), [.next(1, expectedItems)])
    }

    func testSearchIgnoresDuplicates() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let dep = Dependency()

        let expectedItems: [AnyPricable] = [
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake)
        ]

        let mock = MockFetcher(items: expectedItems)
        dep.register(Fetching.self) { _ in
            mock
        }

        let sut = ListViewController.ViewModel(dependency: dep, scheduler: scheduler)
        let itemsObserver = scheduler.createObserver([AnyPricable].self)
        sut.items.bind(to: itemsObserver).disposed(by: bag)

        let searchTerm = faker.lorem.word()

        sut.searchTerm.accept(searchTerm)
        sut.searchTerm.accept(searchTerm)
        sut.searchTerm.accept(searchTerm)
        sut.searchTerm.accept(searchTerm)

        scheduler.start()

        XCTAssertEqual(mock.fetchItemsCallCount, 1)
        XCTAssertEqual(mock.searchTerm, searchTerm)
        XCTAssertEqual(itemsObserver.events.dropFirst(), [.next(1, expectedItems)])
    }

    func testSearchDebounces() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let dep = Dependency()

        let expectedItems: [AnyPricable] = [
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake)
        ]

        let mock = MockFetcher(items: expectedItems)
        dep.register(Fetching.self) { _ in
            mock
        }

        let sut = ListViewController.ViewModel(dependency: dep, scheduler: scheduler)
        let itemsObserver = scheduler.createObserver([AnyPricable].self)
        sut.items.bind(to: itemsObserver).disposed(by: bag)

        sut.searchTerm.accept("h")
        sut.searchTerm.accept("he")
        sut.searchTerm.accept("hel")
        sut.searchTerm.accept("hell")
        sut.searchTerm.accept("hello")

        scheduler.start()

        XCTAssertEqual(mock.fetchItemsCallCount, 1)
        XCTAssertEqual(mock.searchTerm, "hello")
        XCTAssertEqual(itemsObserver.events.dropFirst(), [.next(1, expectedItems)])
    }


    func testSearchCallsFetchItems() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let dep = Dependency()

        let expectedItems: [AnyPricable] = [
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake)
        ]

        let mock = MockFetcher(items: expectedItems)
        dep.register(Fetching.self) { _ in
            mock
        }

        let sut = ListViewController.ViewModel(dependency: dep, scheduler: scheduler)
        let itemsObserver = scheduler.createObserver([AnyPricable].self)
        sut.items.bind(to: itemsObserver).disposed(by: bag)

        let expectedSearchTerm = faker.lorem.word()

        sut.searchTerm.accept(expectedSearchTerm)

        scheduler.start()

        XCTAssertEqual(mock.fetchItemsCallCount, 1)
        XCTAssertEqual(mock.searchTerm, expectedSearchTerm)
        XCTAssertEqual(itemsObserver.events.dropFirst(), [.next(1, expectedItems)])
    }
}

class MockUSDPriceUseCase: USDPriceUseCase {
    var stubbedFetchItemsResult: Observable<[AnyPricable]>!
    override func fetchItems() -> Observable<[AnyPricable]> {
        return stubbedFetchItemsResult
    }
}

class MockAllPriceUseCase: AllPriceUseCase {
    var stubbedFetchItemsResult: Observable<[AnyPricable]>!
    override func fetchItems() -> Observable<[AnyPricable]> {
        return stubbedFetchItemsResult
    }
}

class MockFetcher: Fetching {

    var items: [AnyPricable]
    var fetchItemsCallCount = 0
    var searchTerm: String?

    init(items: [AnyPricable]) {
        self.items = items
    }

    func fetchItems(searchText: String?) -> Observable<[AnyPricable]> {
        searchTerm = searchText
        fetchItemsCallCount += 1
        return Single<[AnyPricable]>.create { [unowned self] in
            $0(.success(items))
            return Disposables.create {}
        }
        .asObservable()
    }
}


