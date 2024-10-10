//
//  ItemDetailsView.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 10/10/2024.
//

import SwiftUI
import RxCombine
import RxSwift

struct ItemDetailView: View {
    let item: AnyPricable
    @StateObject var vm: ViewModel

    init(item: AnyPricable) {
        self.item = item
        self._vm = StateObject(wrappedValue: ViewModel(item: item))
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(vm.warning).font(.title).foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            Text(vm.price).font(.title2)
                .padding(.bottom, 12)
            ForEach(vm.tags, id: \.self) { tag in
                Text(tag)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()

        .navigationTitle(vm.title)

        Spacer()
    }
}

#Preview {
    ItemDetailView(item: AnyPricable(USDPrice(id: 1, name: "ufffff", usd: 1.0, tags: [.deposit])))
}

extension ItemDetailView {
    class ViewModel: ObservableObject {

        @Published var title: String = ""
        @Published var warning: String = ""
        @Published var price: String = ""
        @Published var tags: [String] = []

        init(
            dependency: Dependency = Dependency.shared,
            item: AnyPricable,
            scheduler: SchedulerType = MainScheduler.instance
        ) {

            let allpriceUseCase = dependency.resolve(AllPriceUseCase.self)!
            let featureFlags = dependency.resolve(FeatureFlagProvider.self)!

            let foundPrice =
            Observable.combineLatest(
                allpriceUseCase.fetchItems(),
                featureFlags.observeFlagValue(flag: .supportEUR)
            )
                .observe(on: scheduler)
                .map {
                    let (prices, isEURSupported) = $0

                    guard isEURSupported else {
                        return item
                    }
                    let price = prices.first { $0.id == item.id }
                    return price ?? item
                }
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
                $0 ? "EUR is supported, please select item from list view again" : ""
            }
            .publisher
            .replaceError(with: "")
            .assign(to: &$warning)

        }
    }
}
