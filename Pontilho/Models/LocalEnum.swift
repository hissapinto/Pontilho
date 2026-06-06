//
//  LocalEnum.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 24/07/25.
//

import Foundation
import SwiftUI

enum LocalEnum: String, CaseIterable {
    case park
    case coffee
    case culture
    case restaurant
    case sweet
    
    var color: Color {
        switch self {
            
        case .park:
            return .verdinho
            
        case .coffee:
            return .azulzinho
            
        case .culture:
            return .lilazinho
            
        case .restaurant:
            return .laranjinha
            
        case .sweet:
            return .amarelinho
            
        }
    }
    
    var title: String {
        switch self {
            
        case .park:
            return "Ar livre"
            
        case .coffee:
            return "Cafés"
            
        case .culture:
            return "Cultural"
        
        case .restaurant:
            return "Restaurantes"
            
        case .sweet:
            return "Noitada"
            
        }
    }
    
    var image: String {
        
        switch self {
        case .park:
            return "Bolinhas"
            
        case .coffee:
            return "Cafe"
            
        case .culture:
            return "Livros"
            
        case .restaurant:
            return "Prato"
            
        case .sweet:
            return "Docinho"
            
        }
    }
}
