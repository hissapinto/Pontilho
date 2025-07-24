////
////  LocaisModel.swift
////  Pontilho
////
////  Created by Isabela Hissa Pinto on 15/07/25.
////
//
//
import Foundation
import SwiftUI
import MapKit
//
//
struct LocalModel: Identifiable{
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }    
}
//
//#if DEBUG
//    let cafes: [Local] = [
//        Local(id: UUID(), name: "Árvore do Pão", latitude: -23.5527, longitude: -46.6513, image: "CoffeeShop", qtdEstrelasCheias: 4, qtdEstrelasMeias: 1, jaVisitou: true),
//        Local(id: UUID(), name: "Lógico café", latitude: -23.5445, longitude: -46.6514, image: "CoffeeShop2", qtdEstrelasCheias: 3, qtdEstrelasMeias: 1, jaVisitou: true),
//        Local(id: UUID(), name: "Naïf Café",latitude: -23.5405, longitude: -46.6508, image: "CoffeeShop3"),
//        Local(id: UUID(), name: "Waku Waku",latitude: -23.5416, longitude: -46.6552, image: "CoffeeShop4")
//    ]
//#endif
//
