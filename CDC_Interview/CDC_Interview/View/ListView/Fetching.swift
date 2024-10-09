//
//  Fetching.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 9/10/2024.
//

import RxSwift

protocol Fetching {
    func fetchItems(searchText: String?) -> Observable<[InstrumentPriceCell.ViewModel]>
}
