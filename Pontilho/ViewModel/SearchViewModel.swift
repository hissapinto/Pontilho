//
//  SearchViewModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 06/06/26.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

@Observable
@MainActor
class SearchViewModel {
    ///para a API de imagens do google
    let repository: SearchRepositoryProtocol
    var placesPhotos: [UIImage] = []
    var placeInfo: PlaceInfo?
    var isLoadingPhoto: Bool = false
    var customName: String = ""
    
    init(repository: SearchRepositoryProtocol) {
        self.repository = repository
    }
    
    ///Se comunica com a API e pede as fotos e infos
    func fetchPlacePhotosAndInfo(for local: MKMapItem) async {
        isLoadingPhoto = true
        
        do {
            let result = try await repository.fetchPlacePhotosAndInfo(for: local)
            placesPhotos = result.photos
            placeInfo = result.info
        } catch {
            print(error.localizedDescription)
        }

        isLoadingPhoto = false
    }
    
    func saveSearchedPlace(placeItem: MKMapItem?, type: String, at cdViewModel: CDViewModel) {
        guard let local = placeItem,
              let identifier = local.identifier else { return }
        
        let lat: Double
        let lon: Double
        let add: String
        let grade: String = (placeInfo?.rating.map { String(format: "%.1f", $0) }) ?? ""
        let hour: String = placeInfo?.regularOpeningHour?.joined(separator: "|") ?? "Sem informações de horários"

        if #available(iOS 26.0, *) {
            lat = local.location.coordinate.latitude
            lon = local.location.coordinate.longitude
            add = local.address?.fullAddress ?? "Sem endereço"
        } else {
            lat = local.placemark.coordinate.latitude
            lon = local.placemark.coordinate.longitude
            add = local.placemark.title ?? "Sem endereço"
        }
        
        var photoFiles: [String]? = nil //[URL da fotos]
        if !placesPhotos.isEmpty {
            photoFiles = placesPhotos.prefix(3).compactMap{ ImageStorage.save($0) }
        }

        _ = cdViewModel.createLocal(
            name: local.name ?? "Nome não encontrado",
            latitude: lat,
            longitude: lon,
            type: type,
            identifier: identifier.rawValue,
            address: add,
            grade: grade,
            hour: hour,
            photoFiles: photoFiles
        )
        
        createNotification(local: local, at: cdViewModel)
    }
    
    private func createNotification(local: MKMapItem, at cdViewModel: CDViewModel) {
        let notification: NotificationModel = NotificationModel(title: "Não esqueça de passear!", subtitle: "", body: "Faz uma semana que você salvou: \(local.name ?? "Nome não encontrado")")
        
        NotificationManagerModel.scheduleNotification(notification: notification, cdViewModel: cdViewModel)
    }
}
