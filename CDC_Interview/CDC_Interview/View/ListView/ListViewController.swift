
import UIKit
import RxSwift
import RxCocoa

class ListViewController: UIViewController {

    private let cellId = "InstrumentPriceCell"
    private let tableView = UITableView()
    
    private let searchBar = UISearchBar()
    private let disposeBag = DisposeBag()

    @Observed private var navigateWithPrice: AnyPricable?
    private let vm = ViewModel()

    init(dependency: Dependency = Dependency.shared) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(InstrumentPriceCell.self, forCellReuseIdentifier: cellId)
        tableView.estimatedRowHeight = 80
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.contentInset = UIEdgeInsets(top: searchBar.frame.height,left: 0,bottom: 0,right: 0);
    }

    private func bindViewModel() {
        searchBar.searchTextField.rx
            .text
            .bind(to: vm.searchTerm)
            .disposed(by: disposeBag)

        vm.items
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .bind(to: tableView.rx.items(cellIdentifier: cellId))(Self.configureCell)
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(AnyPricable.self)
            .bind(to: $navigateWithPrice)
            .disposed(by: disposeBag)

        $navigateWithPrice
            .compactMap { $0?.id }
            .subscribe {
                switch $0 {
                case let .next(priceId):
                    self.navigationController?.pushViewController(
                        USDItemDetailsViewController(priceId: priceId),
                        animated: true
                    )
                case let .error(e):
                    print("navigation error: \(e)")
                case .completed:
                    print("navigation finished")
                }
            }
            .disposed(by: disposeBag)
    }

    static func configureCell(index: Int, price: AnyPricable, cell: UITableViewCell) {
        guard let singleCell = cell as? InstrumentPriceCell else {
            return
        }
        singleCell.configure(price: price)
    }
}

extension ListViewController {
    class ViewModel {
        var bag: DisposeBag = .init()
        // input
        var searchTerm: BehaviorRelay<String?> = .init(value: nil)
        // output
        var items: BehaviorRelay<[AnyPricable]> = .init(value: [])

        private var fetcher: Fetching

        init(dependency: Dependency = Dependency.shared, scheduler: SchedulerType = MainScheduler.instance) {
            fetcher = dependency.resolve(Fetching.self)!

            let fetchItems = fetchItems(fetcher: fetcher)

            searchTerm
                .debounce(.milliseconds(300), scheduler: scheduler)
                .distinctUntilChanged()
                .flatMapLatest(fetchItems)
                .asDriver(onErrorDriveWith: .empty())
                .drive(items)
                .disposed(by: bag)
        }
    }

    static func fetchItems(fetcher: Fetching) -> (_ searchTerm: String?) -> Observable<[AnyPricable]> {
        { searchTerm in
            fetcher.fetchItems(searchText: searchTerm)
        }
    }
}

class ItemPriceFetcher: Fetching {

    private let usdUseCase: USDPriceUseCase
    private let allUseCase: AllPriceUseCase
    private let featureFlagProvider: FeatureFlagProvider

    init(dependency: Dependency = Dependency.shared) {
        self.usdUseCase = dependency.resolve(USDPriceUseCase.self)!
        allUseCase = dependency.resolve(AllPriceUseCase.self)!
        self.featureFlagProvider = dependency.resolve(FeatureFlagProvider.self)!
    }

    func fetchItems(searchText: String?) -> Observable<[AnyPricable]> {
        Observable.combineLatest(
            featureFlagProvider.observeFlagValue(flag: .supportEUR),
            usdUseCase.fetchItems()
//            allUseCase.fetchItems()
        ).map { shouldUseNewAPI, usdResult in
            let searchedPrice = usdResult
                .filter {
                    if let searchText, searchText.isEmpty == false {
                        return $0.name.contains(searchText)
                    }
                    return true
                }

            return searchedPrice
        }
    }
}
