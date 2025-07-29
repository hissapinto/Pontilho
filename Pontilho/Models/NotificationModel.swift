//
//  NotificationModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 29/07/25.
//

import Foundation
import SwiftUI

struct NotificationModel {
    public var id: UUID = UUID()
    public var title: String
    public var subtitle: String
    public var body: String
    public var latitude: Double
    public var longitude: Double
    
    init(title: String, subtitle: String, body: String, latitude: Double, longitude: Double) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.latitude = latitude
        self.longitude = longitude
    }
}
