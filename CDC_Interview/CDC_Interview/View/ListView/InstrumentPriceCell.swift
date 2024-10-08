
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
    
    func configure(viewModel: ViewModel) {
        viewModel.titleObservable.asDriver(onErrorDriveWith: .empty())
            .drive(textLabel!.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.descriptionObserable.asDriver(onErrorDriveWith: .empty())
            .drive(detailTextLabel!.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.backgroundColorObservable.asDriver(onErrorDriveWith: .empty())
            .drive(self.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        // only set viewed after 3 seconds
        Observable<Void>.just(())
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                viewModel.hasViewedRelay.accept(true)
            })
            .disposed(by: disposeBag)
    }
}

extension InstrumentPriceCell {
    class ViewModel: Equatable {
        static func == (lhs: InstrumentPriceCell.ViewModel, rhs: InstrumentPriceCell.ViewModel) -> Bool {
            lhs.usdPrice.id == rhs.usdPrice.id
        }
        
        let usdPrice: USDPrice
        let titleObservable: Observable<String>
        let descriptionObserable: Observable<String>
        let backgroundColorObservable: Observable<UIColor>
        let hasViewedRelay: BehaviorRelay<Bool> = .init(value: false)
        
        init(usdPrice: USDPrice) {
            self.usdPrice = usdPrice
            titleObservable = .just(usdPrice.name)
            descriptionObserable = .just("\(usdPrice.usd)")
            backgroundColorObservable = hasViewedRelay.map {
                $0 ? .white : .lightGray
            }
        }
    }
}
