
import UIKit
import RxSwift
import RxCocoa
import SwiftUI

class ListViewController: UIViewController {

    private let cellId = "InstrumentPriceCell"
    private let tableView = UITableView()
    
    private let searchBar = UISearchBar()
    private let disposeBag = DisposeBag()

    private lazy var vm = ViewModel(navigator: navigationController!)

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
            .bind(to: vm.$navigateWithPrice)
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

        var searchTerm: BehaviorRelay<String?> = .init(value: nil)
        var items: BehaviorRelay<[AnyPricable]> = .init(value: [])
        @Observed var navigateWithPrice: AnyPricable?

        private var fetcher: Fetching
        private var flagProvider: FeatureFlagProvider
        private var navigator: Navigating

        init(
            navigator: Navigating,
            dependency: Dependency = Dependency.shared,
            scheduler: SchedulerType = MainScheduler.instance
        ) {
            fetcher = dependency.resolve(Fetching.self)!
            flagProvider = dependency.resolve(FeatureFlagProvider.self)!
            self.navigator = navigator

            let fetchItems = fetchItems(fetcher: fetcher)

            $navigateWithPrice
                .compactMap { $0 }
                .subscribe(onNext:navigator.toDetailView)
                .disposed(by: bag)

            let search$ = searchTerm
                .debounce(.milliseconds(300), scheduler: scheduler)
                .distinctUntilChanged()

            Observable.combineLatest(
                flagProvider.observeFlagValue(flag: .supportEUR).distinctUntilChanged(),
                search$
            )
            .map { $0.1 }
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
