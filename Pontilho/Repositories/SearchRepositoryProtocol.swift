//
//  SearchRepositoryProtocol.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/08/26.
//

import MapKit
import SwiftUI

struct PlaceResults {
    let photos: [UIImage]
    let info: PlaceInfo
    
}

protocol SearchRepositoryProtocol {
    func fetchPlacePhotosAndInfo(for local: MKMapItem) async throws -> PlaceResults
}
