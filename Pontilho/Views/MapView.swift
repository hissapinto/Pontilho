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
    let locations = [
        Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
    ]
    var listas: [Lista]
    
    var body: some View {
        NavigationStack{
            ZStack{
                Map {
                    ForEach(locations) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            Text(location.name)
                                .font(.headline)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(.capsule)
                        }
                        .annotationTitles(.hidden)                }
                }
                VStack{
                    Spacer()
                    ListasScrollView(listas: listas)
                }
                //            MapReader { proxy in
                //                Map()
                //                    .mapStyle(.hybrid)
                //                    .onTapGesture { position in
                //                        if let coordinate = proxy.convert(position, from: .local){
                //                            print(coordinate)
                //                    }
                //                }
                //            }
            }
        }.searchable(text: $searchText)
    }
}

#Preview {
    MapView(listas: listas)
}
