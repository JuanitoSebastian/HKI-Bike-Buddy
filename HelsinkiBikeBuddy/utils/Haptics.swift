//
//  Haptics.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 8.4.2021.
//

import Foundation
import UIKit

class Haptics {

    static let shared = Haptics()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator()

    private init() {}

    func feedback(intensity: Intensity, delay: Int) {
        if delay <= 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay)) {
                self.feedback(intensity: intensity)
            }
        } else {
            feedback(intensity: intensity)
        }
    }

    func feedback(intensity: Intensity) {
        switch intensity {
        case .hard:
            notificationGenerator.notificationOccurred(.success)
        default:
            impactGenerator.impactOccurred(intensity: 1)
        }
    }

    enum Intensity {
        case hard
        case medium
        case soft
    }
}
