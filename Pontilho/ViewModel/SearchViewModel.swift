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
    var placesPhotos: [PlacePhoto] = []
    var placeInfo: PlaceInfo?
    var isLoadingPhoto: Bool = false
    var customName: String = ""

    init(repository: SearchRepositoryProtocol) {
        self.repository = repository
    }

    ///Se comunica com o Repository e pede as fotos e infos retornados da API
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

    ///Salva o local pesquisado no banco de dados.
    ///Compliance (Google Places): só são salvos dados do MapKit (nome, coordenadas, endereço, identifier do Apple Maps).
    ///Fotos, avaliações e horários NÃO são salvos — são buscados ao vivo na exibição.
    func saveSearchedPlace(placeItem: MKMapItem?, type: String, at cdViewModel: CDViewModel) {
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

        _ = cdViewModel.createLocal(
            name: local.name ?? "Nome não encontrado",
            latitude: lat,
            longitude: lon,
            type: type,
            identifier: identifier.rawValue,
            address: add
        )

        createNotification(local: local, at: cdViewModel)
    }

    ///Cria notificação do local salvo
    private func createNotification(local: MKMapItem, at cdViewModel: CDViewModel) {
        let notification: NotificationModel = NotificationModel(title: "Não esqueça de passear!", subtitle: "", body: "Faz uma semana que você salvou: \(local.name ?? "Nome não encontrado")")

        NotificationManagerModel.scheduleNotification(notification: notification, cdViewModel: cdViewModel)
    }
}
