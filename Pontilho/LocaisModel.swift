//
//  LocaisModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//


import Foundation
import SwiftUI


struct Locais{
    let id: UUID = UUID()
    var name: String
    var image: String
    var qtdEstrelasCheias: Int
    var qtdEstrelasMeias: Int
    var jaVisitou: Bool = false
}

