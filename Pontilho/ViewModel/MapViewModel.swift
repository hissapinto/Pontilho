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
@MainActor
class MapViewModel {
    ///Para busca
    var searchText = ""
    var isSearchVisible = false
    var showSheet: Bool = false
    var settingDetent = PresentationDetent.medium
    var placeItem: MKMapItem? = nil //para locais da pesquisa
    private(set) var searchResults: [MKMapItem] = []
    ///Verificadores de que tipo de busca
    var visibleRegion: MKCoordinateRegion?
    var previousVisibleRegion: MKCoordinateRegion?
    private(set) var hasSearchedAtLeastOnce = false
    private var lastSearchDate: Date?
    private(set) var isSearchLocallyVisible = false
    
    
    ///Para visualizar listas
    var showPins: Bool = false
    var typeFilter: String = "nil"
    var previousTypeFilter: String = ""
    var hasPreviousTypeFilter: Bool = false
    
    ///Manipulação de locais
    var selectedLocation: MKMapItem? = nil //para locais salvos nas listas
    var ifselectedLocation: Bool = false
    var didLocalWasCreated: Bool = false //pra enviar notificacao de salvo
    var mapSelection: MapSelection<MKMapItem>? // para Points of interest nativos
    
    ///CoreData
    let cdViewModel: CDViewModel
    var localToDeleteOrOpen: Local? = nil
    var localToDeleteName: String = "Nome não encontrado"
    
    ///User info
    var userLocation: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager() //pra pegar a loc do usuário
    var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    init(cdViewModel: CDViewModel) {
        self.cdViewModel = cdViewModel
    }
    
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
    
    ///Public busca locais usando a localização do usuário como centro
    func peformSearchOnUserLocation(for query: String) async {
        searchResults = await search(for: query, in: userLocation)
        lastSearchDate = Date()
        hasSearchedAtLeastOnce = true
        position = .automatic //posiciona o mapa para mostrar todos os pins
    }
    
    ///Public busca locais usando o centro da tela
    func peformSearchOnVisibleRegion(for query: String) async {
        guard let screenCenter = visibleRegion?.center else { return }
        
        searchResults = await search(for: query, in: screenCenter)
        lastSearchDate = Date()
        //position = .automatic
    }
    
    func isLikelyProgrammaticMove() -> Bool {
        guard let last = lastSearchDate else { return false }
        return Date().timeIntervalSince(last) < 1.5 // 1,5s de "janela morta" após a busca
    }
    
    func resetSearch() {
        searchResults = []
    }
    
    ///Unwarp de nome do local
    func locationNameUnwrapped(_ selectedLocation: MKMapItem?) -> String {
        guard let name = selectedLocation?.name else {
            return "Nome do lugar não encontrado."
        }
        return name
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
    
    ///para ligar a pesquisa por localidade
    func setSearchLocallyVisible() {
        isSearchLocallyVisible = true
    }
    
    ///para desligar a pesquisa por localidade
    func unsetSearchLocallyVisible() {
        isSearchLocallyVisible = false
    }
    
    ///Retorna a distancia do usuário para o centro da tela
    func distanceFromUserToCenter() -> CLLocationDistance? {
        guard let user = userLocation,
              let center = visibleRegion?.center else {
            return nil
        }
        
        let userLoc = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return userLoc.distance(from: centerLoc)
    }
    
    ///Retorna a distancia do do centro da tela anterior para o atual
    func distanceFromPreviousAndActualVisibleRegion() -> CLLocationDistance? {
        guard let prevReg = previousVisibleRegion?.center,
              let actualReg = visibleRegion?.center else {
            return nil
        }
        
        let prevRegLoc = CLLocation(latitude: prevReg.latitude, longitude: prevReg.longitude)
        let actualRegLoc = CLLocation(latitude: actualReg.latitude, longitude: actualReg.longitude)
        return prevRegLoc.distance(from: actualRegLoc)
    }
    
    ///Quando estiver mostrando uma lista
    func selectList(type: LocalEnum) {
        typeFilter = type.rawValue
        
        if previousTypeFilter == typeFilter && hasPreviousTypeFilter == true { //clicou no mesmo botao
            showPins = false
            typeFilter = ""
            hasPreviousTypeFilter = false
        }
        
        else {
            showPins = false
            typeFilter = type.rawValue
            showPins = true
            previousTypeFilter = typeFilter
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
    
    ///Abrir no Mapas com o nome certo
    func openInMapsCustom() {
        if let identifierString = localToDeleteOrOpen?.identifier,
           let identifier = MKMapItem.Identifier(rawValue: identifierString) {
            Task {
                let request = MKMapItemRequest(mapItemIdentifier: identifier)
                if let local = try? await request.mapItem {
                    local.openInMaps()
                    return
                }
                selectedLocation?.openInMaps()
            }
        }
        else {
            selectedLocation?.openInMaps()
        }
    }
    
}
