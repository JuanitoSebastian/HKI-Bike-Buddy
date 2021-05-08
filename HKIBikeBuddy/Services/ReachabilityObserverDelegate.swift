//
//  ReachabilityObserverDelegate.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 4.3.2021.
//

import Foundation
import Reachability

/// Used for determining if the device is connected to the internet
private var reachability: Reachability!

protocol ReachabilityActionDelegate {
    func reachabilityChanged(_ isReachable: Bool)
}

protocol ReachabilityObserverDelegate: AnyObject, ReachabilityActionDelegate {
    func addReachabilityObserver() throws
    func removeReachabilityObserver()
}

extension ReachabilityObserverDelegate {

    func addReachabilityObserver() throws {
        reachability = try Reachability()

        reachability.whenReachable = { [weak self] _ in
            self?.reachabilityChanged(true)
        }

        reachability.whenUnreachable = { [weak self] _ in
            self?.reachabilityChanged(false)
        }

        try reachability.startNotifier()
    }

    func removeReachabilityObserver() {
        reachability.stopNotifier()
        reachability = nil
    }
}
