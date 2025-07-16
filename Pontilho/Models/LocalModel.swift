//
//  LocaisModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//


import Foundation
import SwiftUI
import MapKit


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
    Local(name: "Delícias da vovó", image: "CoffeeShop3", qtdEstrelasCheias: 0, qtdEstrelasMeias: 0),
    Local(name: "Apenas um café", image: "CoffeeShop4", qtdEstrelasCheias: 0, qtdEstrelasMeias: 0)
]

let locations = [
    Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
    Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
]

let position = MapCameraPosition.region(
    MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
    )
)
