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
            let featureFlags = dependency.resolve(FeatureFlagProvider.self)!

            price = item.prices.map { "\($0.currency): \($0.value)" }.joined(separator: "\n")

            title = item.name

            tags = item.tags.map { $0.rawValue }

            featureFlags.observeFlagValue(flag: .supportEUR)
                .map { ($0 && !item.prices.contains { $0.currency == .eur }) ? "EUR is supported, please select item from list view again" : "" }
                .publisher
                .replaceError(with: "")
                .assign(to: &$warning)

        }
    }
}
