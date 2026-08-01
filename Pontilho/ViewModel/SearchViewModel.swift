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
    var placesAPI = PlacesAPI()
    var placesPhotos: [UIImage] = []
    var placeInfo: PlaceInfo?
    var isLoadingPhoto: Bool = false
    var customName: String = ""
    
    ///CoreData
    let cdViewModel: CDViewModel
    
    init(cdViewModel: CDViewModel) {
        self.cdViewModel = cdViewModel
    }
    
    func placeNameUnWrapped(for local: MKMapItem?) -> String {
        guard let local = local, let name = local.name else {
            return customName.isEmpty ? "Nome não encontrado" : customName
        }
        return name
    }
    
    func placeAdressUnwrapped(for local: MKMapItem?) -> String {
        if #available(iOS 26.0, *) {
            guard let local = local, let description = local.address?.fullAddress else {
                return "Sem descrição"
            }
            return description
            
        } else {
            guard let local = local, let description = local.placemark.title else {
                return "Sem descrição"
            }
            return description
        }
    }
    
    func placeTypeUnwrapped(for local: MKMapItem?) -> String {
        guard let local = local, let category = local.pointOfInterestCategory else {
            return "Categoria não encontrada"
        }
        let text = category.rawValue.split(separator: "MKPOICategory")
        return String(text[0])
    }
    
    func placeRatingUnwrapped() -> String {
        guard let placeInfo, placeInfo.rating != nil else {
            return ""
        }
        let rating = "★ " + String(format: "%.2f", placeInfo.rating!)
        return rating
    }
    
    func splitString(text: String) -> [String] {
        let parts = text.split(separator: ": ", maxSplits: 1)
        
        //formato inesperado - devolve o texto
        guard parts.count == 2 else {
                return [text]
        }
        
        let first = String(parts[0]).capitalized
        let second = String(parts[1])
        
        return [first, second]
    }
    
    ///Se comunica com a API e pede as fotos e infos
    func fetchPlacePhotosAndInfo(for local: MKMapItem) async {
        isLoadingPhoto = true
        if let (photos, info) = await placesAPI.fetchPhotoAndInfo(for: local) {
            placesPhotos = photos
            placeInfo = info
        }
        isLoadingPhoto = false
    }
    
    func saveSearchedPlace(placeItem: MKMapItem?, type: String) {
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
        
        createNotification(local: local)
    }
    
    private func createNotification(local: MKMapItem) {
        let notification: NotificationModel = NotificationModel(title: "Não esqueça de passear!", subtitle: "", body: "Faz uma semana que você salvou: \(local.name ?? "Nome não encontrado")")
        
        NotificationManagerModel.scheduleNotification(notification: notification, cdViewModel: cdViewModel)
    }
}
