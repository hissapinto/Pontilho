//
//  ContentView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 14/07/25.
//

import SwiftUI
import MapKit

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    @State private var searchText = ""
    @State var showDetails: Bool = false
    @State var lista: Lista
    @State var locais: [Local]
    @State var selectedLocation: Local?

    let locationManager = CLLocationManager()
    
    var startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -23.55, longitude: -46.653),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    
    var body: some View {
        NavigationStack{
            ZStack{
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        if showDetails {
                            ForEach(lista.locais) { item in
                                Annotation(item.name, coordinate: item.coordinate){
                                    LocalPoint(cor: lista.color)
                                        .onTapGesture {
                                            selectedLocation = item
                                        }
                                }
                            }
                        }
                        UserAnnotation()
                    }
                    //Códigos que influenciam o mapa:
                    .tint(.gray)
                    .onAppear { //permitir loc usuário
                        locationManager.requestWhenInUseAuthorization()
                    }
                    .onTapGesture { position in //Salvar novo local
                        if let coordinate = proxy.convert(position, from: .local) {
                            let newLocation = Local(id: UUID(), name: "Novo Local", latitude: coordinate.latitude, longitude: coordinate.longitude)
                            lista.locais.append(newLocation)

                        }
                    }
                    .mapControls { //Botões do mapa
                        MapUserLocationButton()
                        MapCompass()
                        MapPitchToggle()
                        MapScaleView()
                    }
                    .sheet(item: $selectedLocation) { item in
                        EditView(local: item) { newLocal in
                            if let index = locais.firstIndex(of: item) {
                                locais[index] = newLocal
                            }
                        }
                    }
                }
                VStack{
                    if showDetails {
                        ListaTitle(lista: lista)
                    }
                    Spacer()
                    ListasScrollView(showDetails: $showDetails, listas: listas)
                        .padding(.leading, 15)
                }
            }
        }.searchable(text: $searchText)
    }
}


#Preview {
    MapView(lista: .exemploLista, locais: cafes)
}
