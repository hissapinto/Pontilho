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
    @State private var showSheet: Bool = false
    @State private var settingDetent = PresentationDetent.medium
    @State private var selectedLocation: MKPlacemark? = nil //para locais salvos nas listas
    @State private var placeItem: MKMapItem? = nil
    @State private var selectedLocationLatitude: Double = 0
    @State private var selectedLocationLontigude: Double = 0
    @State private var searchResults: [MKMapItem] = []
    @State private var cityToSearch: String = "Digite seu bairro"
    @State private var showingSheet = false
    
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
                                Annotation(item.name ?? "", coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                                    LocalPoint(localType: .coffee)
                                    //                                        .onTapGesture {
                                    //                                            selectedLocation = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude))
                                    //                                            selectedLocationLatitude = item.latitude
                                    //                                            selectedLocationLontigude = item.longitude
                                    //                                            showSheet.toggle()
                                    //                                        }
                                } //Annotation
                            } //ForEach
                        } //if showDetail
                        //                        List {
                        ForEach(searchResults, id: \.self) { item in
                            Annotation(item: item) {
                                SearchPoint()
                                    .onTapGesture {
                                        showSheet.toggle()
                                    }
                            }
                        }
                    } //Map
                    //func salvar novo local
                    //                    .onTapGesture { position in //Salvar novo local
                    //                        if let coordinate = proxy.convert(position, from: .local) {
                    //                            let newLocation = cdViewModel.createLocal(name: "novo local", latitude: coordinate.latitude, longitude: coordinate.longitude, type: LocalEnum.coffee.rawValue)
                    //                            print(newLocation)
                    //                        }
                    //                    }
                    
                }//MapReader
                .tint(.gray)
                .searchable(text: $searchText, prompt: "O que você quer descobrir?")
                .onAppear { //pedir loc usuário
                    locationManager.requestWhenInUseAuthorization()
                    
                }
                .sheet(isPresented: $showSheet) {
                    EditView()//selectedLocationLatitude: $selectedLocationLatitude, selectedLocationLontigude: $selectedLocationLontigude)
                        .presentationDetents([.medium, .large],
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
                    
                }
                VStack{
                    if showDetails {
                        ListaTitle(localType: .coffee)
                    }
                    Spacer()
                    ListasScrollView(showDetails: $showDetails)
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
