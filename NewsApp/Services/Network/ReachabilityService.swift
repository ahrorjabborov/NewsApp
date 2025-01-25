//
//  ReachabilityService.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import Foundation
import Combine
import Reachability

// not needed anymore
final class ReachabilityService: ObservableObject {
    static let shared = ReachabilityService()
    @Published private(set) var isConnected = false
    private let reachability = try? Reachability()
    private var subscription: AnyCancellable?

    private init() {
        startNotifier()
    }

    private func startNotifier() {
        do { try reachability?.startNotifier() } catch {}
        subscription = NotificationCenter.default.publisher(for: .reachabilityChanged)
            .compactMap { $0.object as? Reachability }
            .map { $0.connection != .unavailable }
            .sink { [weak self] in self?.isConnected = $0 }
    }

    func stop() {
        reachability?.stopNotifier()
        subscription?.cancel()
        subscription = nil
    }

    func restart() {
        stop()
        startNotifier()
    }
}
