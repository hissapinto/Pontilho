//
//  ListaEnum.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 17/07/25.
//
import Foundation
import SwiftUI

enum ListaEnum: String {
    case Favoritos
    case Cafes
    case Doces
    case Cultural
    case Restaurantes
    
    var color: Color {
        switch self {
        case .Favoritos:
            return .verdinho
            
        case .Cafes:
            return .azulzinho
            
        case .Doces:
            return .amarelinho
            
        case .Cultural:
            return .lilazinho
            
        case .Restaurantes:
            return .laranjinha
        }
    }
    
    var listaTitle: String {
        return self.rawValue
    }
}
