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
    var vm: EditViewModel
    
    let localType: LocalEnum
    
    var body: some View{
        Button {
            guard let local = placeItem,
                  let identifier = local.identifier else { return }
            
            let lat: Double
            let lon: Double
            let add: String

            if #available(iOS 26.0, *) {
                lat = local.location.coordinate.latitude
                lon = local.location.coordinate.longitude
                add = local.address?.fullAddress ?? "Sem endereço"
            } else {
                lat = local.placemark.coordinate.latitude
                lon = local.placemark.coordinate.longitude
                add = local.placemark.title ?? "Sem endereço"
            }
            
            var photoName: String? = nil //URL da foto
            if let firstPhoto = vm.placesPhotos.first {
                photoName = ImageStorage.save(firstPhoto)
            }

            _ = cdViewModel.createLocal(
                name: local.name ?? "Nome não encontrado",
                latitude: lat,
                longitude: lon,
                type: type,
                identifier: identifier.rawValue,
                address: add, photoFile: photoName
            )
            
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

    SearchSheetButton(
        type: "coffee",
        placeItem: .constant(mapItem),
        didLocalWasCreated: .constant(false), vm: EditViewModel(),
        localType: .coffee
    )
    .environment(CDViewModel())
}
