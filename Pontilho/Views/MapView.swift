//
//  ContentView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 14/07/25.
//

import SwiftUI
import MapKit


struct MapView: View {
    @State private var searchText = ""
    @ObservedObject var cdViewModel = CDViewModel()
    
    @State var showDetails: Bool = false
    @State var selectedLocation: Local?
    
    let locationManager = CLLocationManager() //pra pegar a loc do usuário
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
//    var startPosition = MapCameraPosition.region(
//        MKCoordinateRegion(
//            center: CLLocationCoordinate2D(
//                latitude: -23.55,
//                longitude: -46.653
//            ),
//            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
//        )
//    )
    
    //QUERIA QUE A PESQUISA APARECESSE NA MINHA REGIÃO
    //TESTE BUSCA CAFE
    @State private var searchResults: [MKMapItem] = []
    
    private func findCity() async -> MKMapItem? { //trabsforma func em pega a posiçao do usuáriocdv
        let request = MKLocalSearch.Request()
        
        //Teste com loc usuário
        //        if let coordUsuario = locationManager.location?.coordinate {
        //            let teste = MKCoordinateRegion(center: coordUsuario, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        //            request.region = teste
        //        }
        
        request.naturalLanguageQuery = "São Paulo"
        
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
        request.regionPriority = .required
        
        let search = MKLocalSearch(request: request)
        
        let response = try? await search.start()
        return response?.mapItems ?? []
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                MapReader { proxy in
                    Map(position: $position) {
                        if showDetails {
                            ForEach(cdViewModel.locais) { item in
                                Annotation(item.name, coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
//                                    LocalPoint(cor: .azulzinho)
                                    }
                                }
                            }
                            //                            ForEach(listaViewModel.first?.listas.locais) { item in
                            //                                Annotation(item.name, coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                            //                                    LocalPoint(cor: UIColor(item.color))
                            //                                        .onTapGesture {
                            //                                            selectedLocation = item
                            //                                        }
                            //                                }
                            //                            }
                        
                        
//                        UserAnnotation()
                        ForEach(searchResults, id: \.self) { item in
                            Marker(item: item)
                        }
                    }
                    
                    //Códigos que influenciam o mapa:
                    .tint(.gray)
                    .onAppear { //permitir loc usuário
                        locationManager.requestWhenInUseAuthorization()
                    }
                    .onTapGesture { position in //Salvar novo local
                        if let coordinate = proxy.convert(position, from: .local) {
                            let newLocation = CDViewModel.createLocal(name: "novo local", latitude: coordinate.longitude, longitude: coordinate.latitude, type: LocalEnum.coffee.rawValue)
                            print(CDViewModel.locais)
                        }
                    }
//                    .mapControls { //Botões do mapa
//                        MapUserLocationButton()
//                        MapCompass()
//                        MapPitchToggle()
//                        MapScaleView()
//                    }
                    //                    .sheet(item: $selectedLocation) { item in
                    //                        EditView(local: item) { newLocal in
                    //                            if let index = listaViewModel.getLista().locais.firstIndex(of: item) {
                    //                                locais[index] = newLocal
                    //                            }
                    //                        }
                }
            }
        }
        .onAppear() {
            CDViewModel.getLocal()
        }
        .onChange(of: searchText) {
            Task {
                guard let SaoPaulo = await findCity() else {
                    return
                }
                
                searchResults = await search(for: searchText, in: SaoPaulo)
            }
//            VStack{
//                if showDetails {
//                    ListaTitle(lista: selectedLista)
//                }
//                Spacer()
//                                    ListasScrollView(showDetails: $showDetails, listas: listaViewModel.getLista())
//                                        .padding(.leading, 15)
//            }
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    MapView()
}
