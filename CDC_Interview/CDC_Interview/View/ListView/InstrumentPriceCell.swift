
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

        viewModel.$title.asDriver(onErrorDriveWith: .empty())
            .drive(textLabel!.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.$description.asDriver(onErrorDriveWith: .empty())
            .drive(detailTextLabel!.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.$backgroundColor.asDriver(onErrorDriveWith: .empty())
            .drive(self.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
}

extension InstrumentPriceCell {
    class ViewModel {

        var bag: DisposeBag = .init()

        @Observed var price: (AnyPricable)?
        @Observed var title: String = ""
        @Observed var description: String = ""
        @Observed var backgroundColor: UIColor = .white
        @Observed var hasViewed: Bool = false

        init(scheduler: SchedulerType = MainScheduler.instance) {
            $price
                .map { $0?.name ?? "" }
                .bind(to: $title)
                .disposed(by: bag)

            $price
                .compactMap { $0?.prices }
                .map(Self.toUSDPrice)
                .bind(to: $description)
                .disposed(by: bag)

            $hasViewed
                .map { $0 ? .white : .lightGray }
                .bind(to: $backgroundColor)
                .disposed(by: bag)

            // only set viewed after 3 seconds
            Observable<Void>.just(())
                .delay(.seconds(3), scheduler: scheduler)
                .subscribe(onNext: { [unowned self] in
                    hasViewed = true
                })
                .disposed(by: bag)
        }

        static func toUSDPrice(prices: [Price]) -> String {
            "\(prices.first { $0.currency == .usd }?.value ?? 0)"
        }
    }
}
