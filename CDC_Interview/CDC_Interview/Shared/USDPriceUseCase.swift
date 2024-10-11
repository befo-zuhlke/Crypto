
import Foundation
import RxSwift
import RxCocoa

class USDPriceUseCase {
    private let disposeBag = DisposeBag()

    func fetchItems(scheduler: SchedulerType = MainScheduler.instance) -> Observable<[AnyPricable]> {
        let itemsObservable = Observable<[AnyPricable]>.create { observer in

            let path = Bundle.main.path(forResource: "usdPrices", ofType: "json")!
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                observer.onError(NSError(domain: "File Error", code: 404, userInfo: nil))
                observer.onCompleted()
                return Disposables.create()
            }

            do {
                let items = try JSONDecoder().decode([USDPrice].self, from: data)
                observer.onNext(items.map(AnyPricable.init))
                observer.onCompleted()
            } catch {
                observer.onError(NSError(domain: "Decoding Error: \(error)", code: 0, userInfo: nil))
                observer.onCompleted()
            }

            return Disposables.create()
        }
            .delay(.seconds(2), scheduler: scheduler)

        return itemsObservable
    }
}
