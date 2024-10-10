//
//  Navigator.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 10/10/2024.
//

import UIKit
import SwiftUI

extension UINavigationController: Navigating {
    func toDetailView(price: AnyPricable) {
        pushViewController(UIHostingController(rootView: ItemDetailView(item: price)), animated: true)
    }
}

protocol Navigating {
    func toDetailView(price: AnyPricable)
}
