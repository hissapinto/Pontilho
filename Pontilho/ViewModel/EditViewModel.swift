//
//  EditViewModel.swift
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
class EditViewModel {
    ///para a API de imagens do google
    var placesAPI = PlacesAPI()
    var placesPhotos: [UIImage] = []
    var isLoadingPhoto: Bool = false
    var customName: String = ""
    
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
    
    ///Se comunica com a API e pede as fotos
    func fetchPlacePhotos(for local: MKMapItem) async {
        isLoadingPhoto = true
        placesPhotos = await placesAPI.fetchPhoto(for: local)
        isLoadingPhoto = false
    }
    
}
