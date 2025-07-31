//
//  MapView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 25/07/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var searchText = ""
    @ObservedObject var cdViewModel = CDViewModel()
    @State private var showDetails: Bool = false
    @State private var typeFilter: String = ""
    @State private var showSheet: Bool = false
    @State private var settingDetent = PresentationDetent.medium
    @State private var selectedLocation: MKMapItem? = nil //para locais salvos nas listas
    @State private var ifselectedLocation: Bool = false
    @State private var localToDelete: Local? = nil
    @State private var localToDeleteName: String = "Nome não encontrado"
    @State private var placeItem: MKMapItem? = nil //para locais da pesquisa

    @State private var searchResults: [MKMapItem] = []
    @State private var cityToSearch: String = "Digite sua cidade e bairro"
    
    let locationManager = CLLocationManager() //pra pegar a loc do usuário
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var didLocalWasCreated: Bool = false //pra enviar notificacao
    
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
    
    func locationNameUnwrapped(_ selectedLocation: MKMapItem?) -> String {
        if selectedLocation == nil {
            return "Lugar não encontrado."
        } else if selectedLocation!.name == nil {
            return "Nome do lugar não encontrado."
        } else {
            return selectedLocation!.name!
        }
    }
    
    func localToDeletUnwrapped(_ local: Local?) -> Local {
        do {
            let novoLocal = local!
            return novoLocal
        } catch {
            print("[WARNING]: Failed to find Local (\(error.localizedDescription))")
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                MapReader { proxy in
                    Map(position: $position) {
                        if showDetails {
                            ForEach(cdViewModel.locais) { item in
                                if typeFilter == item.type {
                                    Annotation(item.name ?? "", coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                                        LocalPoint(localType: typeFilter)
                                            .onTapGesture{
                                                selectedLocation = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)))
                                                ifselectedLocation = true
                                                localToDelete = item
                                                localToDeleteName = item.name!
                                            }
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
                .tint(.pretinho)
                .searchable(text: $searchText, prompt: "O que você quer descobrir?")
                .onAppear { //pedir loc usuário
                    locationManager.requestWhenInUseAuthorization()
                }
                .sheet(isPresented: $showSheet) {
                    EditView(placeItem: $placeItem, didLocalWasCreated: $didLocalWasCreated)
                        .presentationDetents([.height(220)],
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
                    NotificationManagerModel.requirePermissions()
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
                .alert(localToDeleteName, isPresented: $ifselectedLocation, actions: {
                    Button("Abrir no Mapas") {
                        selectedLocation?.openInMaps()
                        ifselectedLocation = false
                    }
                    Button("Cancelar", role: .cancel) {
                        ifselectedLocation = false
                    }
                    Button(role: .destructive) {
                        cdViewModel.deleteLocal(localToDeletUnwrapped(localToDelete))
                        cdViewModel.getLocal()
                        ifselectedLocation = false
                    } label: {
                        Text("Deletar da lista")
                    }
                })
                VStack{
                    if showDetails {
                        ListaTitle(localType: typeFilter)
                    }
                    Spacer() //if se sheet tiver on desliga a listascrolview
                    ListasScrollView(showDetails: $showDetails, typeFilter: $typeFilter)
                        .padding(.leading, 15)
                }
            }
            .overlay(
                ZStack {
                    VStack{
                        if didLocalWasCreated {
                            LocalToast()
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .zIndex(1) // Ensure toast is on top
                                .padding(.top, 10)
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Position at the top
            )
            .navigationTitle($cityToSearch)
            .navigationBarTitleDisplayMode(.inline)
        }//NavigationStack
    }
}


#Preview {
    MapView()
}
