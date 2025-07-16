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
    
    let position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    var listas: [Lista]
    
    var body: some View {
        NavigationStack{
            ZStack{
                Map(initialPosition: position) {
                    if showDetails{
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
                }
                VStack{
                    Spacer()
                    ListasScrollView(showDetails: $showDetails, listas: listas)
                }
            }
        }.searchable(text: $searchText)
    }
}

#Preview {
    MapView(listas: listas)
}
