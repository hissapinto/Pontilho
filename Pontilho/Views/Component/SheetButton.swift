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
    
    var body: some View{
        Button {
            guard let local = placeItem,
                  let identifier = local.identifier else { return }
            
            _ = cdViewModel.createLocal(name: local.name ?? "Nome não encontrado", latitude: local.placemark.coordinate.latitude, longitude: local.placemark.coordinate.longitude, type: type, identifier: identifier.rawValue)
            
            let notification: NotificationModel = NotificationModel(title: "Não esqueça de passear!", subtitle: "", body: "Faz uma semana que você salvou: \(local.name ?? "Nome não encontrado")")
            
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

#Preview {
    let coordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)

    SheetButton(
        type: "coffee",
        placeItem: .constant(mapItem),
        didLocalWasCreated: .constant(false),
        localType: .coffee
    )
    .environment(CDViewModel())
}
