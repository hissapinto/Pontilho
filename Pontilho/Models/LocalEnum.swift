//
//  LocalEnum.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 24/07/25.
//

import Foundation
import SwiftUI

enum LocalEnum: String {
    case coffee
    case park
    case restaurant
    case sweet
    case culture
    
    var color: Color {
        switch self {
        case .coffee:
            return .azulzinho
            
        case .park:
            return .verdinho
            
        case .restaurant:
            return .laranjinha
            
        case .sweet:
            return .amarelinho
            
        case .culture:
            return .lilazinho
            
        }
    }
    
    var title: String {
        switch self {
        case .coffee:
            return "Cafés"
            
        case .park:
            return "Parques"
            
        case .restaurant:
            return "Restaurantes"
            
        case .sweet:
            return "Docinhos"
            
        case .culture:
            return "Cultural"
            
        }
    }
    
    var image: String {
        switch self {
        case .coffee:
            return "Cafe"
            
        case .park:
            return "Bolinhas"
            
        case .restaurant:
            return "Prato"
            
        case .sweet:
            return "Docinho"
            
        case .culture:
            return "Livros"
            
        }
    }
}
