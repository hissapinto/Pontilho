//
//  SearchButton.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 28/07/25.
//

import Foundation
import SwiftUI
import MapKit

struct SheetButton: View {
    var type: String
    @Environment(CDViewModel.self) private var cdViewModel
    @Binding var placeItem: MKMapItem?
    @Binding var didLocalWasCreated: Bool
    
    let localType: LocalEnum
    
    func placeNameUnWrapped() -> String {
        guard ((placeItem?.name) != nil) else {
            return "Nome não encontrado"
        }
        return placeItem!.name!
    }
    
    func placeAdressUnwrapped() -> String {
        guard ((placeItem?.placemark.title) != nil) else {
            return "Sem descrição"
        }
        return placeItem!.placemark.title!
    }
    
    func placeLatitudeUnwrapped(_ placeItem: MKMapItem?) -> Double {
        guard let placeItem = placeItem else {
            fatalError()
        }
        return placeItem.placemark.coordinate.latitude
    }
    
    func placeLongitudeUnwrapped(_ placeItem: MKMapItem?) -> Double {
        guard let placeItem = placeItem else {
            fatalError()
        }
        return placeItem.placemark.coordinate.longitude
    }
    
    func placeIdentifierUnwrapped(_ placeItem: MKMapItem?) -> String {
        guard let identifier = placeItem?.identifier else {
            return "Sem nome"
        }
        return identifier.rawValue
    }
    
    var body: some View{
        Button {
            _ = cdViewModel.createLocal(name: placeNameUnWrapped(), latitude: placeLatitudeUnwrapped(placeItem), longitude: placeLongitudeUnwrapped(placeItem), type: type, identifier: placeIdentifierUnwrapped(placeItem))
            let notification: NotificationModel = NotificationModel(title: "Não esqueça de passear!", subtitle: "", body: "Faz uma semana que você salvou: \(placeNameUnWrapped())")
            NotificationManagerModel.scheduleNotification(notification: notification, cdViewModel: cdViewModel)
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

//#Preview {
//    // Define a coordinate
//    let coordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437) // Los Angeles
//    
//    // Create an MKPlacemark
//    let placemark = MKPlacemark(coordinate: coordinate)
//    
//    // Create an MKMapItem from the placemark
//    let mapItem = MKMapItem(placemark: placemark)
//    
//    SheetButton(type: "coffee", placeItem: .constant(mapItem) , didLocalWasCreated: .constant(false), localType: .coffee)
//}
