//
//  PlacesAPI.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 06/06/26.
//

import Foundation
import GooglePlacesSwift
import MapKit

@MainActor
class PlacesAPI {
    let client = PlacesClient.shared
    
    ///Busca fotos de um MapItem
    func fetchPhoto(for place: MKMapItem, near location: CLLocationCoordinate2D) async -> [UIImage] {
        guard let name = place.name else { return [] }
        let region = CircularCoordinateRegion(center: location, radius: 11000)
        
        ///Define a busca: nome x e de resultado quero fotos
        let request = SearchByTextRequest(textQuery: name, placeProperties: [.photos], locationBias: region)
        
        ///Busca e resultados
        switch await client.responseForSearchByText(with: request) {
            
        case .success(let response):
            guard let place = response.places?.first else { return [] }
            guard let photoMetadata = place.photos, !photoMetadata.isEmpty else { return [] }
            var images: [UIImage] = []
            
            ///Parallel for
            await withTaskGroup(of: UIImage?.self) { group in
    
                for mData in photoMetadata.prefix(5) {
                    group.addTask {
                        ///Define a busca da foto
                        let photoRequest = FetchPhotoRequest(photo: mData, maxSize: CGSize(width: 600, height: 500))
                        ///Ativamente busca
                        switch await self.client.fetchPhoto(with: photoRequest) {
                        case .success(let image): return image
                        case .failure(_): return nil
                        }
                    }
                }
                
                ///Aguarda retornos
                for await image in group {
                    if let image = image {
                        images.append(image)
                    }
                }
                
            }
            return images
            
        case .failure:
            return []
        }
        
    }
}
