//
//  SearchButton.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 28/07/25.
//

import Foundation
import SwiftUI
import MapKit

struct SearchSheetButton: View {
    var type: String
    @Environment(CDViewModel.self) private var cdViewModel
    @Binding var placeItem: MKMapItem?
    @Binding var didLocalWasCreated: Bool
    var vm: SearchViewModel
    
    let localType: LocalEnum
    
    var body: some View{
        Button {
            vm.saveSearchedPlace(placeItem: placeItem, type: type, at: cdViewModel)
            withAnimation {
                didLocalWasCreated = true
            }
            // Dismiss after 2 seconds (toast)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    didLocalWasCreated = false
                }
            }
        } label: {
            ListaButton(localType: localType)
        }
    }
    
}

#Preview {
    let coordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    
    let rep = SearchRepository()
    let searchVM = SearchViewModel(repository: rep)

    SearchSheetButton(
        type: "coffee",
        placeItem: .constant(mapItem),
        didLocalWasCreated: .constant(false), vm: searchVM,
        localType: .coffee
    )
    .environment(CDViewModel())
}
