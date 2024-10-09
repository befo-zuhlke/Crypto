
import Foundation
import UIKit
import RxSwift
import RxCocoa

class USDItemDetailsViewController: UIViewController {
    private let warningLabel: UILabel = .init()
    private let priceLabel: UILabel = .init()
    private let tagsStackView: UIStackView = .init()

    private let disposeBag = DisposeBag()
    
    let titleObservable: Observable<String>
    let warningObservable: Observable<String?>
    let priceObservable: Observable<String>
    let tagsObservable: Observable<[String]>
    let priceId: Int
    
    let usdUseCase: USDPriceUseCase
    let allUseCase: AllPriceUseCase
    
    init(priceId: Int) {
        self.usdUseCase = Dependency.shared.resolve(USDPriceUseCase.self)!
        self.allUseCase = Dependency.shared.resolve(AllPriceUseCase.self)!
        let featureFlagProvider = Dependency.shared.resolve(FeatureFlagProvider.self)!
        self.priceId = priceId
        
        let fetchedObservable: Observable<Pricable?> = usdUseCase.fetchItems()
            .observe(on: MainScheduler.instance)
            .map { items in
                return items.first { $0.id == priceId }
            }
        
        self.titleObservable = fetchedObservable.map {
            $0?.name ?? "-"
        }
        
        self.priceObservable = fetchedObservable.map {
            $0?.prices.map { "Price: $\($0.currency) - \($0.value)" }.joined(separator: "\n") ?? "Price: $-"
        }
        
        self.tagsObservable = fetchedObservable.map {
            $0?.tags.map { $0.rawValue } ?? []
        }
        
        self.warningObservable = featureFlagProvider.observeFlagValue(flag: .supportEUR)
            .map { isEURSupported in
                if isEURSupported {
                    return "EUR is supported, please select item from list view again"
                }
                
                return nil
            }
        
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
        tagsStackView.axis = .vertical
        let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 40))
        
        let vStack = UIStackView(arrangedSubviews: [
            warningLabel,
            priceLabel,
            tagsStackView,
            emptyView
        ])
        vStack.spacing = 8
        
        warningLabel.textColor = .red
        vStack.axis = .vertical
        vStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8),
            vStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 8)
        ])
        
        self.hidesBottomBarWhenPushed = true
        self.view.backgroundColor = .white
    }
   
    private func bindViewModel() {
        titleObservable
            .do(onNext: { title in
                self.title = title
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        warningObservable
            .subscribe(onNext: {
                self.warningLabel.text = $0
            })
            .disposed(by: disposeBag)
        
        priceObservable
            .bind(to: priceLabel.rx.text)
            .disposed(by: disposeBag)
        
        tagsObservable.subscribe(onNext: { tags in
            for tag in tags {
                let label = UILabel()
                label.text = tag
                self.tagsStackView.addArrangedSubview(label)
            }
        }).disposed(by: disposeBag)
    }
}

class USDItemDetailsViewModel {
    
}
