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
    
    let startPosition = MapCameraPosition.region(
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
                                }
                            }
                            
                        }
                    }
                    
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            let newLocation = Local(id: UUID(), name: "Novo Local", latitude: coordinate.latitude, longitude: coordinate.longitude)
                            lista.locais.append(newLocation)
                            
                        }
                    }
                }
                VStack{
                    if showDetails {
                        ListaTitle(lista: listas.first!)
                    }
                    Spacer()
                    ListasScrollView(showDetails: $showDetails, listas: listas)
                        .padding(.leading, 15)
                }
            }
        }.searchable(text: $searchText, isPresented: $showDetails )
    }
}


#Preview {
    MapView(lista: Lista(name: "Favoritos", image: "EstrelaCheia", color: .verdinho, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed commodo,  tellus vitae blandit sollicitudin, purus dui pellentesque felis, sed  consequat est nunc vitae massa.", locais: cafes), locais: cafes)
}
