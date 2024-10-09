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
        VStack {
            Text(vm.warning)
            Text(vm.title)
            Text(vm.price)
            ForEach(vm.tags, id: \.self) { tag in
                Text(tag)
            }
        }
    }
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

            let foundPrice = allpriceUseCase.fetchItems()
                .observe(on: scheduler)
                .map { $0.first { $0.id == item.id } ?? item }
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
