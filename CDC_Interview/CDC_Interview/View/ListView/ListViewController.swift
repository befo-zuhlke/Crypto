
import UIKit
import RxSwift
import RxCocoa

class ListViewController: UIViewController {
    private let tableView = UITableView()
    
    private let searchBar = UISearchBar()
    private let disposeBag = DisposeBag()
    
    var itemsObservable: Observable<[InstrumentPriceCell.ViewModel]> {
        itemsRelay.asObservable()
    }
    
    private var itemsRelay: BehaviorRelay<[InstrumentPriceCell.ViewModel]> = .init(value: [])
    private let usdUseCase: USDPriceUseCase
    private let allUseCase: AllPriceUseCase
    private let featureFlagProvider: FeatureFlagProvider
    
    init(dependency: Dependency = Dependency.shared) {
        self.usdUseCase = dependency.resolve(USDPriceUseCase.self)!
        allUseCase = dependency.resolve(AllPriceUseCase.self)!
        self.featureFlagProvider = dependency.resolve(FeatureFlagProvider.self)!
        
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
        
        tableView.register(InstrumentPriceCell.self, forCellReuseIdentifier: "InstrumentPriceCell")
        tableView.estimatedRowHeight = 80
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.contentInset = UIEdgeInsets(top: searchBar.frame.height,left: 0,bottom: 0,right: 0);
    }
    
    private func bindViewModel() {
        itemsObservable
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .bind(to: tableView.rx.items(cellIdentifier: "InstrumentPriceCell")) { index, vm, cell in
                guard let singleCell = cell as? InstrumentPriceCell else {
                    return
                }
                singleCell.configure(viewModel: vm)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .withLatestFrom(itemsObservable) { ($0, $1) }
            .map { indexPath, items in
                let vm = items[indexPath.row]
                
                // TODO: if 'supportEUR' feature flag is on, we need to route to a Price Detail View Controller which able to show both EUR + USD prices.
                self.navigationController?.pushViewController(USDItemDetailsViewController(priceId: vm.usdPrice.id), animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        // Fetch the items from the ViewModel
        searchBar.searchTextField.rx.text.asDriver().flatMapLatest { searchText in
            self.fetchItems(searchText: searchText).asDriver(onErrorDriveWith: .empty())
        }
        .drive()
    }
}

extension ListViewController {
    func fetchItems(searchText: String?) -> Observable<Void> {
        Observable.combineLatest(
            featureFlagProvider.observeFlagValue(falg: .supportEUR),
            usdUseCase.fetchItems()
            // allUseCase.fetchItems()
        )
        .do(onNext: { shouldUseNewAPI, usdResult in
            guard shouldUseNewAPI else {
                let viewModels = usdResult
                    .filter {
                        if let searchText, searchText.isEmpty == false {
                            return  $0.name.contains(searchText)
                        }
                        return true
                    }
                    .map { InstrumentPriceCell.ViewModel.init(usdPrice: $0) }
                self.itemsRelay.accept(viewModels) 
                return
            }
            
            // TODO: need to handle new api
            
        }, onSubscribe: {
            self.itemsRelay.accept([])
        }).map { _ in }
    }
}
