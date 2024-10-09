
import UIKit
import RxSwift
import RxCocoa
import Combine
import SwiftUI

typealias SettingViewController = UIHostingController<SettingView>


struct SettingView: View {
    @StateObject var viewModel: SettingModel = .init()
    var body: some View {
        VStack {
            Toggle("Support EUR", isOn: $viewModel.supportEUR)
        }
    }
}

class SettingModel: ObservableObject {

    var bag = Set<AnyCancellable>()

    @Published var supportEUR: Bool = false {
        didSet {
            featureFlagProvider.update(flag: .supportEUR, newValue: supportEUR)
        }
    }
    
    let featureFlagProvider: FeatureFlagProvider
    
    init() {
        self.featureFlagProvider = Dependency.shared.resolve(FeatureFlagProvider.self)!
        self.supportEUR = self.featureFlagProvider.getValue(flag: .supportEUR)

        $supportEUR.sink { [unowned self] in
            featureFlagProvider.update(flag: .supportEUR, newValue: $0)
        }
        .store(in: &bag)
    }
}

#Preview {
    SettingView(viewModel: .init())
}
