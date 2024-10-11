
import Foundation
import RxSwift
import RxCocoa

class AllPriceUseCase {
    private let disposeBag = DisposeBag()

    func fetchItems(scheduler: SchedulerType = MainScheduler.instance) -> Observable<[AnyPricable]> {
        let itemsObservable = Observable<[AnyPricable]>.create { observer in

            let path = Bundle.main.path(forResource: "allPrices", ofType: "json")!

            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let allPrices = try JSONDecoder().decode(AllPrice.self, from: data)

                observer.onNext(allPrices.data.map(AnyPricable.init))
                observer.onCompleted()
            } catch {
                observer.onError(NSError(domain: "File Error", code: 404, userInfo: nil))
                return Disposables.create()
            }


            return Disposables.create()
        }
            .delay(.seconds(2), scheduler: scheduler)

        return itemsObservable
    }
}

