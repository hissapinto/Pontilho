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
    func fetchPhoto(for place: MKMapItem) async -> [UIImage] {
        guard let name = place.name else { return [] }
        let coordinate = place.placemark.coordinate
        let restriction = CircularCoordinateRegion(center: coordinate, radius: 200)
        
        ///Define a busca: nome x e de resultado quero fotos
        let request = SearchByTextRequest(textQuery: name, placeProperties: [.photos, .coordinate], locationRestriction: restriction)
        
        ///Busca e resultados
        switch await client.responseForSearchByText(with: request) {
            
        case .success(let response):
            let places = response.places ?? []
            let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            let placesComDist = places.map { p -> (place: Place, dist: CLLocationDistance) in
                let coord = p.location
                let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                return (p, target.distance(from: loc))
            }.sorted { $0.dist < $1.dist }
            
            guard let melhor = placesComDist.first, melhor.dist < 100 else {
                return []
            }
            
            let place = melhor.place
            guard let photoMetadata = place.photos, !photoMetadata.isEmpty else {
                return []
            }

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
                        case .failure(let error):
                            print("ERRO fetchPhoto (foto): \(error)")
                            return nil
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
            
        case .failure(let error):
            print("ERRO fetchPhoto (foto): \(error)")
            return []
        }
        
    }
}
