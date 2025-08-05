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
    @State private var userLocation: CLLocationCoordinate2D?
    
    @State private var searchResults: [MKMapItem] = []
    let locationManager = CLLocationManager() //pra pegar a loc do usuário
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var didLocalWasCreated: Bool = false //pra enviar notificacao
    
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
        guard let local = local else {
            fatalError()
        }
        return local
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
                .searchable(text: $searchText, prompt: "pesquisar")
                .onAppear { //pedir loc usuário
                    locationManager.requestWhenInUseAuthorization()
                    if let location = locationManager.location?.coordinate {
                        userLocation = location
                    }
                }
                .sheet(isPresented: $showSheet) {
                    EditView(placeItem: $placeItem, didLocalWasCreated: $didLocalWasCreated)
                        .presentationDetents([.height(250)],
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
                        searchResults = await search(for: searchText, in: userLocation)
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
            } //Zstack
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline) //Pra conseguir mudar font nav title
            .toolbar { //Pra conseguir mudar font nav title
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Explore sua região")
                            .font(.system(.largeTitle, design: .serif, weight: .heavy))
                            .italic()
                            .padding(.bottom, 5)
                        Spacer()
                    }
                }
            }
        }//NavigationStack
    }
}


#Preview {
    MapView()
}
