//
//  SearchButtonScroll.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 28/07/25.
//

import SwiftUI
import MapKit

struct SheetButtonScroll: View {
    @Binding var type: String
    @Binding var placeItem: MKMapItem?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack{
                SheetButton(type: type, placeItem: $placeItem, localType: .coffee)
                SheetButton(type: type, placeItem: $placeItem, localType: .park)
                SheetButton(type: type, placeItem: $placeItem, localType: .culture)
                SheetButton(type: type, placeItem: $placeItem, localType: .restaurant)
                SheetButton(type: type, placeItem: $placeItem, localType: .sweet)

            }
        }.padding(.leading, 10)
    }
}


#Preview {
    // Define a coordinate
    let coordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437) // Los Angeles

    // Create an MKPlacemark
    let placemark = MKPlacemark(coordinate: coordinate)

    // Create an MKMapItem from the placemark
    let mapItem = MKMapItem(placemark: placemark)
    
    SheetButtonScroll(type: .constant("coffee"), placeItem: .constant(mapItem))
}
