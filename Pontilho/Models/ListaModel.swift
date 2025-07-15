//
//  Model.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 14/07/25.
//

import Foundation
import SwiftUI

struct Lista{
    let id: UUID = UUID()
    var name: String
    var image: String
    var color: UIColor
}

var listas: [Lista] = [
    Lista(name: "Café", image: "Cafe", color: .azulzinho),
    Lista(name: "Favoritos", image: "EstrelaCheia", color: .verdinho),
    Lista(name: "Docinhos", image: "Docinho", color: .amarelinho),
    Lista(name: "Cultural", image: "Livros", color: .laranjinha),
    Lista(name: "Restaurantes", image: "Prato", color: .lilazinho)
]
