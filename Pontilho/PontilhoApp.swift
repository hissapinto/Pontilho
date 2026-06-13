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
    @State private var cdViewModel = CDViewModel()
    
    init() {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String else {
            fatalError("[ERROR]: GOOGLE_PLACES_API_KEY não encontrada no Info.plist")
        }
        _ = PlacesClient.provideAPIKey(key)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(cdViewModel)
        }
    }
}
