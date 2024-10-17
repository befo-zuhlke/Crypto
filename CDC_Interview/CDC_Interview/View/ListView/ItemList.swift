//
//  ItemList.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 12/10/2024.
//

import SwiftUI
import Combine
import RxCombine
import RxSwift

struct LandingView: View {

    @State private var searchText = ""
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                // Main Content
                TabView(selection: $selectedTab) {
                    ItemList()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(0)

                    SettingView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(1)
                }
            }
        }
    }
}

struct ItemList: View {

    @StateObject var vm = ViewModel()

    var body: some View {
        NavigationView{
            List {
                ForEach(vm.items, id: \.id) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        InstrumentPrice(price: .constant(item))
                    }
                }
            }
        }
        .searchable(text: $vm.searchTerm)
    }

}



extension ItemList {
    class ViewModel: ObservableObject {
        var bag = Set<AnyCancellable>()

        @Published var searchTerm: String = ""
        @Published var items: [AnyPricable] = []

        private var fetcher: Fetching
        private var flagProvider: FeatureFlagProvider

        init(
            dependency: Dependency = Dependency.shared,
            scheduler: SchedulerType = MainScheduler.instance
        ) {
            fetcher = dependency.resolve(Fetching.self)!
            flagProvider = dependency.resolve(FeatureFlagProvider.self)!

            let fetchItems = fetchItems(fetcher: fetcher)

            let search$ = $searchTerm
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .removeDuplicates(by: ==)
                .eraseToAnyPublisher()

            Publishers.CombineLatest(
                flagProvider.observeFlagValue(flag: .supportEUR).distinctUntilChanged().asPublisher().replaceError(with: false),
                search$
            )
            .map { $0.1 }
            .map(fetchItems)
            .switchToLatest()
            .replaceError(with: [])
            .assign(to: &$items)
        }
    }

    static func fetchItems(fetcher: Fetching) -> (_ searchTerm: String?) -> AnyPublisher<[AnyPricable], Error> {
        { searchTerm in
            fetcher.fetchItems(searchText: searchTerm).asPublisher()
        }
    }
}

struct InstrumentPrice: UIViewRepresentable {
    @Binding var price: AnyPricable

    func makeUIView(context: Context) -> InstrumentPriceCell {
        InstrumentPriceCell()
    }

    func updateUIView(_ uiView: InstrumentPriceCell, context: Context) {
        uiView.configure(price: price)
    }
}

#Preview {
    LandingView()
}
