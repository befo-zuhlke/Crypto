
import Foundation
import UIKit
import RxSwift
import RxCocoa

class InstrumentPriceCell: UITableViewCell {
    private(set) var disposeBag: DisposeBag = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let viewModel = ViewModel()

    func configure(price: AnyPricable) {
        viewModel.price = price

        viewModel.title$.asDriver(onErrorDriveWith: .empty())
            .drive(textLabel!.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.description$.asDriver(onErrorDriveWith: .empty())
            .drive(detailTextLabel!.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.backgroundColor$.asDriver(onErrorDriveWith: .empty())
            .drive(self.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        // only set viewed after 3 seconds
        Observable<Void>.just(())
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                viewModel.hasViewed$.accept(true)
            })
            .disposed(by: disposeBag)
    }
}

extension InstrumentPriceCell {
    class ViewModel: Equatable {
        static func == (lhs: InstrumentPriceCell.ViewModel, rhs: InstrumentPriceCell.ViewModel) -> Bool {
            lhs.price?.id == rhs.price?.id
        }

        var bag: DisposeBag = .init()

        @Observed var price: (AnyPricable)?

        let title$: BehaviorRelay<String> = .init(value: "")
        let description$: BehaviorRelay<String> = .init(value: "")
        let backgroundColor$: BehaviorRelay<UIColor> = .init(value: .white)
        let hasViewed$: BehaviorRelay<Bool> = .init(value: false)

        init() {
            $price
                .map { $0?.name ?? "" }
                .bind(to: title$)
                .disposed(by: bag)

            $price
                .compactMap { $0?.prices }
                .map(Self.toUSDPrice)
                .bind(to: description$)
                .disposed(by: bag)

            hasViewed$
                .map { $0 ? .white : .lightGray }
                .bind(to: backgroundColor$)
                .disposed(by: bag)
        }

        static func toUSDPrice(prices: [Price]) -> String {
            "\(prices.first { $0.currency == "usd" }?.value ?? 0)"
        }
    }
}

@propertyWrapper
struct Observed<Value> {
    private let subject: BehaviorSubject<Value>

    var wrappedValue: Value {
        get {
            do {
                return try subject.value()
            } catch {
                fatalError("Could not retrieve value from BehaviorSubject: \(error)")
            }
        }
        set {
            subject.onNext(newValue)
        }
    }

    var projectedValue: BehaviorSubject<Value> {
        return subject
    }

    init(wrappedValue: Value) {
        self.subject = BehaviorSubject<Value>(value: wrappedValue)
    }
}
