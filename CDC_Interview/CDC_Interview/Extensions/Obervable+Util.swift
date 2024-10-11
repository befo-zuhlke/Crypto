//
//  Obervable+Util.swift
//  CDC_Interview
//
//  Created by Ben Fowler on 10/10/2024.
//

import RxSwift

@propertyWrapper
struct Observed<Value> {
    private let subject: BehaviorSubject<Value>

    var wrappedValue: Value {
        get {
            do {
                return try subject.value()
            } catch {
                fatalError("Could not retrieve value from BehaviorSubject: \(error)")
            }
        }
        set {
            subject.onNext(newValue)
        }
    }

    var projectedValue: BehaviorSubject<Value> {
        return subject
    }

    init(wrappedValue: Value) {
        self.subject = BehaviorSubject<Value>(value: wrappedValue)
    }
}
