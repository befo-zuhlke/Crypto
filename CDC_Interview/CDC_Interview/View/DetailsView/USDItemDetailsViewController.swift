
import Foundation
import UIKit
import RxSwift
import RxCocoa
import Combine
import RxCombine

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
        
        let fetchedObservable: Observable<AnyPricable?> = usdUseCase.fetchItems()
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

import SwiftUI

struct ItemDetailView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

extension ItemDetailView {
    class ViewModel: ObservableObject {

        @Published var title: String?
        @Published var warning: String?
        @Published var price: String?
        @Published var tags: [String] = []

        init(
            dependency: Dependency = Dependency.shared,
            item: AnyPricable,
            scheduler: SchedulerType = MainScheduler.instance
        ) {

            let allpriceUseCase = dependency.resolve(AllPriceUseCase.self)!
            let featureFlags = dependency.resolve(FeatureFlagProvider.self)!

            let foundPrice = allpriceUseCase.fetchItems()
                .observe(on: scheduler)
                .compactMap { $0.first { $0.id == item.id } }
                .share()

            foundPrice.publisher
                .map(\.prices)
                .map { $0.map { "\($0.currency): \($0.value)" }.joined(separator: "\n") }
                .eraseToAnyPublisher()
                .replaceError(with: "")
                .assign(to: &$price)

            foundPrice.publisher
                .map(\.name)
                .replaceError(with: "")
                .assign(to: &$title)

            foundPrice.publisher
                .map(\.tags)
                .map { $0.map { $0.rawValue } }
                .replaceError(with: [])
                .assign(to: &$tags)

            featureFlags.observeFlagValue(flag: .supportEUR).map {
                $0 ? "EUR is supported, please select item from list view again" : nil
            }
            .publisher
            .replaceError(with: nil)
            .assign(to: &$warning)

        }
    }
}


