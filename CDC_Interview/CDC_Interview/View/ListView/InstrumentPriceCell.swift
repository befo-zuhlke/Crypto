
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

    func configure(viewModel: ViewModel) {
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
            .subscribe(onNext: {
                viewModel.hasViewed$.accept(true)
            })
            .disposed(by: disposeBag)
    }
}

extension InstrumentPriceCell {
    class ViewModel: Equatable {
        static func == (lhs: InstrumentPriceCell.ViewModel, rhs: InstrumentPriceCell.ViewModel) -> Bool {
            lhs.usdPrice?.id == rhs.usdPrice?.id
        }

        var bag: DisposeBag = .init()

        @Observed var usdPrice: USDPrice?

        let title$: BehaviorRelay<String> = .init(value: "")
        let description$: BehaviorRelay<String> = .init(value: "")
        let backgroundColor$: BehaviorRelay<UIColor> = .init(value: .white)
        let hasViewed$: BehaviorRelay<Bool> = .init(value: false)

        init() {
            $usdPrice
                .map { $0?.name ?? "" }
                .bind(to: title$)
                .disposed(by: bag)

            $usdPrice
                .compactMap { "\($0?.usd ?? 0)" }
                .bind(to: description$)
                .disposed(by: bag)

            hasViewed$
                .map { $0 ? .white : .lightGray }
                .bind(to: backgroundColor$)
                .disposed(by: bag)
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
