//
//  SettingsViewModelTests.swift
//  CDC_InterviewTests
//
//  Created by Ben Fowler on 11/10/2024.
//

import Testing
@testable import CDC_Interview

struct SettingsViewModelTests {

    @Test("initial value for EU support is false")
    func initialValue() async throws {

        let dep = Dependency()

        let mock = MockFeatureFlagProvider()
        dep.register(FeatureFlagProvider.self) { _ in
            mock.result = false
            return mock
        }

        let sut = SettingView.ViewModel(dependency: dep)
        #expect(sut.supportEUR == false)
    }

    @Test("updates feature flag when toggling to true")
    func stuff() async throws {

        let dep = Dependency()

        let mock = MockFeatureFlagProvider()
        dep.register(FeatureFlagProvider.self) { _ in
            mock.result = true
            return mock
        }

        let sut = SettingView.ViewModel(dependency: dep)

        sut.supportEUR = true

        #expect(mock.getValue(flag: .supportEUR) == true)
        #expect(mock.updateCallCount == 2)
        #expect(mock.updateArgs == (.supportEUR, true))
    }

}
