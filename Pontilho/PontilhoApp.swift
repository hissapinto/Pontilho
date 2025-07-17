//
//  PontilhoApp.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 14/07/25.
//

import SwiftUI

@main
struct PontilhoApp: App {
    var body: some Scene {
        WindowGroup {
            MapView(lista: Lista(name: "Favoritos", image: "EstrelaCheia", color: .verdinho, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed commodo,  tellus vitae blandit sollicitudin, purus dui pellentesque felis, sed  consequat est nunc vitae massa.", locais: cafes), locais: cafes)
        }
    }
}
