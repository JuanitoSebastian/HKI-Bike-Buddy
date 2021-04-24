//
//  Notification.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 20.4.2021.
//

import Foundation

struct NotificationContent: Identifiable {

    var id = UUID()
    let title: String
    let text: String

}
