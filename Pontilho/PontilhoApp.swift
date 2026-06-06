//
//  PontilhoApp.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 14/07/25.
//

import SwiftUI
import GooglePlacesSwift

@main
struct PontilhoApp: App {
    
    init() {
        _ = PlacesClient.provideAPIKey("AIzaSyDq0EVItE5h2D8Trrguz0vaWrPniC1huSY")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
