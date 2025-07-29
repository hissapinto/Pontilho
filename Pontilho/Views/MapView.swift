//
//  MapView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 25/07/25.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @State private var searchText = ""
    @ObservedObject var cdViewModel = CDViewModel()
    @State private var showDetails: Bool = false
    @State private var typeFilter: String = ""
    @State private var showSheet: Bool = false
    @State private var settingDetent = PresentationDetent.medium
    @State private var selectedLocation: MKPlacemark? = nil //para locais salvos nas listas
    @State private var placeItem: MKMapItem? = nil

    @State private var searchResults: [MKMapItem] = []
    @State private var cityToSearch: String = "Digite seu bairro"
    
    let locationManager = CLLocationManager() //pra pegar a loc do usuário
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    private func findCity(city: String) async -> MKMapItem? { //trabsforma func em pega a posiçao do usuáriocdv
        let request = MKLocalSearch.Request()
        
        if city == "Digite seu bairro" {
            request.naturalLanguageQuery = "São Paulo"
        } else {
            request.naturalLanguageQuery = city
        }
        
        request.addressFilter = MKAddressFilter(
            including: .locality)
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        return response?.mapItems.first
    }
    
    private func search(for query: String, in city: MKMapItem) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let downtown = MKCoordinateRegion(
            center: city.placemark.coordinate,
            span: .init(latitudeDelta: 0.1,
                        longitudeDelta: 0.1)
        )
        
        request.region = downtown
        request.regionPriority = .required //limitar busca na minha região
        
        let search = MKLocalSearch(request: request)
        
        let response = try? await search.start()
        return response?.mapItems ?? []
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                MapReader { proxy in
                    Map(position: $position, selection: $selectedLocation) {
                        if showDetails {
                            ForEach(cdViewModel.locais) { item in
                                if typeFilter == item.type {
                                    Annotation(item.name ?? "", coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                                        LocalPoint(localType: typeFilter)
                                    } //Annotation
                                }//if
                            }//ForEach
                        } //if showDetail
                        ForEach(searchResults, id: \.self) { item in
                            Annotation(item: item) {
                                SearchPoint()
                                    .onTapGesture {
                                        placeItem = item
                                        showSheet.toggle()
                                    }
                            }
                        }
                    } //Map
                }//MapReader
                .tint(.gray)
                .searchable(text: $searchText, prompt: "O que você quer descobrir?")
                .onAppear { //pedir loc usuário
                    locationManager.requestWhenInUseAuthorization()
                    
                }
                .sheet(isPresented: $showSheet) {
                    EditView(placeItem: $placeItem)
                        .presentationDetents([.height(280)],
                                             selection: $settingDetent)
                }
                .mapControls { //Botões do mapa
                    MapUserLocationButton()
                    MapCompass()
                    MapPitchToggle()
                    MapScaleView()
                }
                .onAppear() {
                    cdViewModel.getLocal()
                }
                .onChange(of: searchText) {
                    Task {
                        guard let SaoPaulo = await findCity(city: cityToSearch) else {
                            return
                        }
                        
                        searchResults = await search(for: searchText, in: SaoPaulo)
                        position = .automatic
                    }
                    cdViewModel.getLocal()
                    showDetails = false
                }
                VStack{
                    if showDetails {
                        ListaTitle(localType: typeFilter)
                    }
                    Spacer()
                    ListasScrollView(showDetails: $showDetails, typeFilter: $typeFilter)
                        .padding(.leading, 15)
                }
            }
            .navigationTitle($cityToSearch)
            .navigationBarTitleDisplayMode(.inline)
        }//NavigationStack
    }
}


#Preview {
    MapView()
}
