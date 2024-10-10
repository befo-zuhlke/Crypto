
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

        dep.register(FeatureFlagProvider.self) { _ in
            FeatureFlagProvider()
        }

        dep.register(Navigating.self) { _ in
            MockNavigator()
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
        dep.register(FeatureFlagProvider.self) { _ in
            FeatureFlagProvider()
        }
        dep.register(Navigating.self) { _ in
            MockNavigator()
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
        dep.register(FeatureFlagProvider.self) { _ in
            FeatureFlagProvider()
        }
        dep.register(Navigating.self) { _ in
            MockNavigator()
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

        dep.register(FeatureFlagProvider.self) { _ in
            FeatureFlagProvider()
        }

        dep.register(Navigating.self) { _ in
            MockNavigator()
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

    func testFeatureFlagCallsV1Api() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let dep = Dependency()

        let expectedItems: [AnyPricable] = [
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake),
            AnyPricable(USDPrice.fake)
        ]

        dep.register(FeatureFlagProvider.self) { _ in
            let mockFeatureFlag = MockFeatureFlagProvider()
            mockFeatureFlag.result = false
            return mockFeatureFlag
        }

        let mockUsd = MockUSDPriceUseCase()

        dep.register(USDPriceUseCase.self) { _ in
            mockUsd.stubbedFetchItemsResult = scheduler.createColdObservable([.next(1, expectedItems)]).asObservable()
            return mockUsd
        }

        let mockAll = MockAllPriceUseCase()
        dep.register(AllPriceUseCase.self) { _ in
            mockAll.stubbedFetchItemsResult = scheduler.createColdObservable([.next(1, [
                AnyPricable(AllPrice.Price.fake),
                AnyPricable(AllPrice.Price.fake),
                AnyPricable(AllPrice.Price.fake)
            ])]).asObservable()
            return mockAll
        }

        dep.register(Fetching.self) { _ in
            ItemPriceFetcher(dependency: dep)
        }

        dep.register(FeatureFlagProvider.self) { _ in
            FeatureFlagProvider()
        }

        let mockNav = MockNavigator()
        dep.register(Navigating.self) { _ in
            mockNav
        }

        let sut = ListViewController.ViewModel(dependency: dep, scheduler: scheduler)
        let itemsObserver = scheduler.createObserver([AnyPricable].self)
        sut.items.bind(to: itemsObserver).disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(itemsObserver.events.dropFirst(), [.next(2, expectedItems)])
    }

    func testFeatureFlagCallsV2Api() {
        let bag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let dep = Dependency()

        let expectedItems: [AnyPricable] = [
            AnyPricable(AllPrice.Price.fake)
        ]

        dep.register(FeatureFlagProvider.self) { resolver in
            let mockFeatureFlag = MockFeatureFlagProvider()
            mockFeatureFlag.result = true
            return mockFeatureFlag
        }

        let mockUsd = MockUSDPriceUseCase()

        dep.register(USDPriceUseCase.self) { _ in
            mockUsd.stubbedFetchItemsResult = scheduler.createColdObservable([
                .next(1, [
                    AnyPricable(USDPrice.fake),
                    AnyPricable(USDPrice.fake),
                    AnyPricable(USDPrice.fake)
                ])
            ]).asObservable()
            return mockUsd
        }

        let mockAll = MockAllPriceUseCase()
        dep.register(AllPriceUseCase.self) { _ in
            mockAll.stubbedFetchItemsResult = scheduler.createColdObservable(
                [.next(1, expectedItems)]
            ).asObservable()
            return mockAll
        }

        dep.register(Fetching.self) { _ in
            ItemPriceFetcher(dependency: dep)
        }

        let mockNav = MockNavigator()
        dep.register(Navigating.self) { _ in
            mockNav
        }

        let sut = ListViewController.ViewModel(dependency: dep, scheduler: scheduler)
        let itemsObserver = scheduler.createObserver([AnyPricable].self)
        sut.items.bind(to: itemsObserver).disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(itemsObserver.events.dropFirst(), [.next(2, expectedItems)])
    }

    func testNavigatesToDetail() {
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

        dep.register(FeatureFlagProvider.self) { _ in
            FeatureFlagProvider()
        }

        let mockNav = MockNavigator()
        dep.register(Navigating.self) { _ in
            mockNav
        }

        let sut = ListViewController.ViewModel(dependency: dep, scheduler: scheduler)
        let itemsObserver = scheduler.createObserver([AnyPricable].self)
        sut.items.bind(to: itemsObserver).disposed(by: bag)

        let fake = AnyPricable(USDPrice.fake)
        sut.navigateWithPrice = fake

        scheduler.start()

        XCTAssertEqual(mockNav.callCount, 1)
        XCTAssertEqual(mockNav.toDetailViewArgs, fake)
    }
}
