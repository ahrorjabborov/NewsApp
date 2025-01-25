//
//  SplashViewModel.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import Foundation
import Combine

// not needed anymore
final class SplashViewModel: ObservableObject {
    @Published var isConnected = false
    private var bag = Set<AnyCancellable>()
    private let service = ReachabilityService.shared

    init() {
        service.$isConnected
            .sink { [weak self] value in
                self?.isConnected = value
            }
            .store(in: &bag)
    }

    func retry() {
        bag.removeAll()
        service.restart()
        service.$isConnected
            .sink { [weak self] value in
                self?.isConnected = value
            }
            .store(in: &bag)
    }
}
