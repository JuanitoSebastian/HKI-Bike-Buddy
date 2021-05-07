//
//  Haptics.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 8.4.2021.
//

import Foundation
import UIKit

/// A class for generating haptic feedback 📱
/// Accessed via singleton instance shared
class Haptics {

    static let shared = Haptics()

    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator()

    private init() {}

    /// Generates a haptic vibration
    /// - Parameter intensity: The intensity of the vibration
    /// - Parameter delay: An optional delay for the vibration. If left empty no delay is added.
    func feedback(intensity: Intensity, delay: Int = 0) {
        if delay <= 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay)) {
                self.feedback(intensity: intensity)
            }
        } else {
            feedback(intensity: intensity)
        }
    }
    /// Generates a haptic vibration
    /// - Parameter intensity: The intensity of the vibration
    private func feedback(intensity: Intensity) {
        switch intensity {
        case .hard:
            notificationGenerator.notificationOccurred(.success)
        case .medium:
            impactGenerator.impactOccurred(intensity: 1.5)
        case .soft:
            impactGenerator.impactOccurred(intensity: 1)
        }
    }

    enum Intensity {
        case hard
        case medium
        case soft
    }
}
