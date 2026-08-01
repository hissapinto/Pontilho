//
//  SearchRepository.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/08/26.
//

import MapKit
import SwiftUI

enum SearchRepositoryError: Error {
    case dataNotFound
}

@MainActor
class SearchRepository: SearchRepositoryProtocol {
    private var placesAPI = PlacesAPI()
    
    func fetchPlacePhotosAndInfo(for local: MKMapItem) async throws -> PlaceResults {
        
        guard let (photos, info) = await placesAPI.fetchPhotoAndInfo(for: local) else {
            throw SearchRepositoryError.dataNotFound
        }
        
        return PlaceResults(photos: photos, info: info)
    }
}
