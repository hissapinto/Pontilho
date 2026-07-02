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
    func fetchPhotoAndInfo(for place: MKMapItem) async -> ([UIImage], PlaceInfo)? {
        guard let name = place.name else { return nil }
        let coordinate = place.placemark.coordinate
        let restriction = CircularCoordinateRegion(center: coordinate, radius: 400)
        
        ///Define a busca: nome x e de resultado quero fotos
        let request = SearchByTextRequest(textQuery: name, placeProperties: [.photos, .coordinate, .displayName, .regularOpeningHours, .rating], locationRestriction: restriction)
        //TODO: - Pegar opening hours e rating
        
        ///Busca e resultados
        switch await client.responseForSearchByText(with: request) {
            
        case .success(let response):
            let places = response.places ?? []
            let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            //print("sucesso | places encontrados: \(places.count)")
            
            let placesComDist = places.map { p -> (place: Place, dist: CLLocationDistance) in
                let coord = p.location
                let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                return (p, target.distance(from: loc))
            }.sorted { $0.dist < $1.dist }
            
            for item in placesComDist.prefix(5) {
                    print(" - \(item.place.displayName ?? "?") | \(Int(item.dist))m")
            }
            
            guard let melhor = placesComDist.first, melhor.dist < 100 else {
                print("nenhum candidato próximo o suficiente")
                return nil
            }
            
            let place = melhor.place
            guard let photoMetadata = place.photos, !photoMetadata.isEmpty else {
                print("place '\(place.displayName ?? "?")' sem fotos")
                return nil
            }

            //print("escolhido: \(place.displayName ?? "?") | \(Int(melhor.dist))m | fotos: \(photoMetadata.count)")
            
            var info: PlaceInfo = PlaceInfo(regularOpeningHour: place.regularOpeningHours?.weekdayText, rating: place.rating)
            var images: [UIImage] = []
            
            ///Parallel for
            await withTaskGroup(of: UIImage?.self) { group in
    
                for mData in photoMetadata.prefix(7) {
                    group.addTask {
                        ///Define a busca da foto
                        let photoRequest = FetchPhotoRequest(photo: mData, maxSize: CGSize(width: 800, height: 600))
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
            return (images, info)
            
        case .failure(let error):
            print("ERRO fetchPhoto (foto): \(error)")
            return nil
        }
        
    }
}


struct PlaceInfo {
    let regularOpeningHour: [String]?
    let rating: Float?
}
