//
//  LocalEnum.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 24/07/25.
//

import Foundation
import SwiftUI
import MapKit

enum LocalEnum: String, CaseIterable {
    case park
    case coffee
    case culture
    case restaurant
    /// Saídas à noite. O rawValue continua "sweet" porque é o texto já salvo no Core Data
    case night = "sweet"
    
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
            
        case .night:
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
            
        case .night:
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
            
        case .night:
            return "Docinho"
            
        }
    }
    
    // MARK: - MapKit (Roteiro do dia)

    /// Lista do Pontilho que mais combina com a categoria do MapKit (para comparar com o gosto)
    init?(category: MKPointOfInterestCategory?) {
        switch category {
        case .park, .nationalPark, .beach, .zoo, .amusementPark, .hiking, .skatePark: self = .park
        case .cafe, .bakery: self = .coffee
        case .museum, .library, .theater, .movieTheater, .planetarium, .aquarium,
             .landmark, .nationalMonument, .castle, .fortress, .conventionCenter, .fairground: self = .culture
        case .restaurant, .foodMarket: self = .restaurant
        case .nightlife, .brewery, .winery, .distillery, .musicVenue: self = .night
        default: return nil
        }
    }

    /// Categorias do MapKit de cada lista (o inverso do init acima), para o plano B da busca
    var mapKitCategories: [MKPointOfInterestCategory] {
        switch self {
        case .park: return [.park, .nationalPark, .beach, .zoo, .amusementPark, .hiking, .skatePark]
        case .coffee: return [.cafe, .bakery]
        case .culture: return [.museum, .library, .theater, .movieTheater, .planetarium, .aquarium,
                               .landmark, .nationalMonument, .castle, .fortress, .conventionCenter, .fairground]
        case .restaurant: return [.restaurant, .foodMarket]
        case .night: return [.nightlife, .brewery, .winery, .distillery, .musicVenue]
        }
    }

    /// Termos de busca do MapKit para cada lista (sorteados quando a pessoa não pediu nada)
    var searchTerms: [String] {
        switch self {
        case .park: return ["parque", "praça", "praia"]
        case .coffee: return ["café", "padaria", "cafeteria", "café da manhã", "doceria", "confeitaria"]
        case .culture: return ["museu", "livraria", "centro cultural", "teatro", "cinema"]
        case .restaurant: return ["restaurante", "comida japonesa", "pizzaria", "comida brasileira", "sorveteria"]
        case .night: return ["bar", "boteco", "casa noturna", "música ao vivo"]
        }
    }
}
