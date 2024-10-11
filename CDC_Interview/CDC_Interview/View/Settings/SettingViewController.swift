
import UIKit
import RxSwift
import RxCocoa
import Combine
import SwiftUI

typealias SettingViewController = UIHostingController<SettingView>


struct SettingView: View {
    @StateObject var viewModel: ViewModel = .init()
    var body: some View {
        VStack {
            Toggle("Support EUR", isOn: $viewModel.supportEUR)
        }
        .padding()
    }
}

extension SettingView {
    class ViewModel: ObservableObject {

        var bag = Set<AnyCancellable>()

        @Published var supportEUR: Bool = false
        let featureFlagProvider: FeatureFlagProvider

        init(dependency: Dependency = Dependency.shared) {
            self.featureFlagProvider = dependency.resolve(FeatureFlagProvider.self)!
            self.supportEUR = self.featureFlagProvider.getValue(flag: .supportEUR)

            $supportEUR
                .removeDuplicates()
                .sink { [unowned self] in
                featureFlagProvider.update(flag: .supportEUR, newValue: $0)
            }
            .store(in: &bag)
        }
    }
}


#Preview {
    SettingView(viewModel: .init())
}
