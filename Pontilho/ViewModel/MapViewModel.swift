//
//  MapViewModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 05/06/26.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

@Observable
class MapViewModel {
    ///Para busca
    var searchText = ""
    var isSearchVisible = false
    var showSheet: Bool = false
    var settingDetent = PresentationDetent.medium
    var placeItem: MKMapItem? = nil //para locais da pesquisa
    private(set) var searchResults: [MKMapItem] = []
    
    ///Para visualizar listas
    var showPins: Bool = false
    var typeFilter: String = "nil"
    var previourTypeFilter: String = ""
    var hasPreviousTypeFilter: Bool = false
    
    ///Manipulação de locais
    var selectedLocation: MKMapItem? = nil //para locais salvos nas listas
    var ifselectedLocation: Bool = false
    var didLocalWasCreated: Bool = false //pra enviar notificacao de salvo
    
    ///CoreData
    var cdViewModel = CDViewModel()
    var localToDelete: Local? = nil
    var localToDeleteName: String = "Nome não encontrado"
    
    ///User info
    private var userLocation: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager() //pra pegar a loc do usuário
    var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    ///Busca locais em relação a localização do usuário.
    private func search(for query: String, in userLocation: CLLocationCoordinate2D?) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let locationToBeUsed = userLocation ?? CLLocationCoordinate2D(latitude: -23.5489, longitude: -46.6388) // ou SP
        let downtown = MKCoordinateRegion(center: locationToBeUsed, span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        request.region = downtown
        request.regionPriority = .required //limitar busca na minha região
        
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        return response?.mapItems ?? []
    }
    
    ///Public busca locais
    func peformSearch(for query: String) async {
        searchResults = await search(for: query, in: userLocation)
        position = .automatic //posiciona o mapa para mostrar todos os pins
    }
    
    ///Unwarp de nome do local
    func locationNameUnwrapped(_ selectedLocation: MKMapItem?) -> String {
        if selectedLocation == nil {
            return "Lugar não encontrado."
        } else if selectedLocation!.name == nil {
            return "Nome do lugar não encontrado."
        } else {
            return selectedLocation!.name!
        }
    }
    
    ///Unwrap de local a ser deletado
    func localToDeletUnwrapped(_ local: Local?) -> Local {
        guard let local = local else {
            fatalError()
        }
        return local
    }
    
    ///Pedir localização usuário
    func requestUserAutorization() {
        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location?.coordinate {
            userLocation = location
        }
    }
    
    ///Retorna localizaçao usuário
    func getUserLocation() -> MapCameraPosition {
        return position
    }
    
    ///Quando estiver mostrando uma lista
    func selectList(type: LocalEnum) {
        typeFilter = type.rawValue
        
        if previourTypeFilter == typeFilter && hasPreviousTypeFilter == true { //clicou no mesmo botao
            showPins = false
            typeFilter = ""
            hasPreviousTypeFilter = false
        }
        
        else {
            showPins = false
            typeFilter = type.rawValue
            showPins = true
            previourTypeFilter = typeFilter
            isSearchVisible = false
            hasPreviousTypeFilter = true
            searchResults = []
        }
        
    }
    
    ///Quando estiver mostrando a barra de pesquisa
    func deselectList() {
        showPins = false
        typeFilter = ""
        isSearchVisible = true
    }
    
}
