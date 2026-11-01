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

    ///Busca fotos e infos de um MapItem, ao vivo.
    ///Compliance (Google Places): nada do que vem daqui deve ser salvo no Core Data.
    func fetchPhotoAndInfo(for place: MKMapItem) async -> ([PlacePhoto], PlaceInfo)? {
        guard let name = place.name else { return nil }
        let coordinate = place.placemark.coordinate
        let restriction = CircularCoordinateRegion(center: coordinate, radius: 400)

        ///Define a busca: nome x e de resultado quero fotos
        let request = SearchByTextRequest(textQuery: name, placeProperties: [.photos, .coordinate, .displayName, .regularOpeningHours, .rating], locationRestriction: restriction)

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
                return nil
            }

            let place = melhor.place
            let photoMetadata = Array((place.photos ?? []).prefix(7))

            let info = PlaceInfo(
                regularOpeningHour: place.regularOpeningHours?.weekdayText,
                rating: place.rating
            )

            ///Parallel for — guarda o índice para manter a ordem e ligar cada foto aos seus créditos
            var loaded: [(index: Int, image: UIImage)] = []
            await withTaskGroup(of: (Int, UIImage?).self) { group in
                for (index, mData) in photoMetadata.enumerated() {
                    group.addTask {
                        ///Define a busca da foto
                        let photoRequest = FetchPhotoRequest(photo: mData, maxSize: CGSize(width: 800, height: 600))
                        ///Ativamente busca
                        switch await self.client.fetchPhoto(with: photoRequest) {
                        case .success(let image): return (index, image)
                        case .failure(let error):
                            print("ERRO fetchPhoto (foto): \(error)")
                            return (index, nil)
                        }
                    }
                }

                ///Aguarda retornos
                for await (index, image) in group {
                    if let image = image {
                        loaded.append((index, image))
                    }
                }
            }

            let photos = loaded
                .sorted { $0.index < $1.index }
                .map { PlacePhoto(id: $0.index,
                                  image: $0.image,
                                  credits: credits(for: photoMetadata[$0.index])) }

            return (photos, info)

        case .failure(let error):
            print("ERRO fetchPhotoAndInfo (busca): \(error)")
            return nil
        }
    }

    ///Créditos de uma foto (autores e atribuições de terceiros) — exibição obrigatória pelo Google.
    private func credits(for photo: GooglePlacesSwift.Photo) -> [PhotoAttribution] {
        var result: [PhotoAttribution] = []
        for author in photo.authorAttributions {
            let credit = PhotoAttribution(name: author.displayName, url: author.url)
            if !result.contains(credit) {
                result.append(credit)
            }
        }
        if let extra = photo.attributions {
            let text = String(extra.characters)
            let credit = PhotoAttribution(name: text, url: nil)
            if !text.isEmpty && !result.contains(credit) {
                result.append(credit)
            }
        }
        return result
    }
}


struct PlaceInfo {
    let regularOpeningHour: [String]?
    let rating: Float?
}

/// Uma foto do Google com os créditos dos seus autores.
struct PlacePhoto: Identifiable {
    let id: Int
    let image: UIImage
    let credits: [PhotoAttribution]
}

/// Crédito do autor de uma foto do Google (nome + link do perfil, quando houver).
struct PhotoAttribution: Hashable {
    let name: String
    let url: URL?
}
