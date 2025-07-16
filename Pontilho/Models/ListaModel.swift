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
    var description: String
    var locais: [Local]
}

var listas: [Lista] = [
    Lista(name: "Favoritos", image: "EstrelaCheia", color: .verdinho, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed commodo,  tellus vitae blandit sollicitudin, purus dui pellentesque felis, sed  consequat est nunc vitae massa.", locais: cafes),
    Lista(name: "Cafezinhos", image: "Cafe", color: .azulzinho, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed commodo,  tellus vitae blandit sollicitudin, purus dui pellentesque felis, sed  consequat est nunc vitae massa.", locais: cafes),
    Lista(name: "Docinhos", image: "Docinho", color: .amarelinho, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed commodo,  tellus vitae blandit sollicitudin, purus dui pellentesque felis, sed  consequat est nunc vitae massa.", locais: cafes),
    Lista(name: "Cultural", image: "Livros", color: .laranjinha, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed commodo,  tellus vitae blandit sollicitudin, purus dui pellentesque felis, sed  consequat est nunc vitae massa.", locais: cafes),
    Lista(name: "Restaurantes", image: "Prato", color: .lilazinho, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed commodo,  tellus vitae blandit sollicitudin, purus dui pellentesque felis, sed  consequat est nunc vitae massa.", locais: cafes)
]


// fazer um enum ou algo que relacione a posição na lista com o botão a ser clicado que seja escalável (o usuário pode fazer N listas)
