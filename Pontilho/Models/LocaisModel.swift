//
//  LocaisModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//


import Foundation
import SwiftUI


struct Local{
    let id: UUID = UUID()
    var name: String
    var image: String
    var qtdEstrelasCheias: Int
    var qtdEstrelasMeias: Int
    var jaVisitou: Bool = false
}

var cafes: [Local] = [
    Local(name: "Árvore do Pão", image: "CoffeeShop", qtdEstrelasCheias: 4, qtdEstrelasMeias: 1, jaVisitou: true),
    Local(name: "Café legal", image: "CoffeeShop2", qtdEstrelasCheias: 3, qtdEstrelasMeias: 1, jaVisitou: true),
    Local(name: "Apenas um café", image: "CoffeeShop3", qtdEstrelasCheias: 0, qtdEstrelasMeias: 0)
]
