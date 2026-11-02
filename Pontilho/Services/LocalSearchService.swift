//
//  LocalSearchService.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/11/26.
//

import Foundation
import MapKit

/// Busca de pontos de interesse com o MapKit (dados da Apple), com cache curto em memória.
@MainActor
final class LocalSearchService {

    private struct Entry {
        let items: [MKMapItem]
        let date: Date
    }

    /// Cache por termo + região (5 minutos)
    private var cache: [String: Entry] = [:]
    private let cacheValidity: TimeInterval = 5 * 60

    /// Centros de bairros/regiões já encontrados
    private var areaCenters: [String: CLLocationCoordinate2D] = [:]

    /// Busca `term` num raio (em metros) ao redor de `center`
    func search(term: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) async -> [MKMapItem] {
        let key = cacheKey(term: term, center: center, radius: radius)
        if let entry = cache[key], Date().timeIntervalSince(entry.date) < cacheValidity {
            return entry.items
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = term
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(center: center,
                                            latitudinalMeters: radius * 2,
                                            longitudinalMeters: radius * 2)
        request.regionPriority = .required
        ///Tira o que não é passeio (táxi, estacionamento, posto…)
        request.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [
            .parking, .gasStation, .evCharger, .publicTransport, .carRental, .atm, .bank,
            .hospital, .pharmacy, .police, .fireStation, .postOffice, .laundry, .restroom, .airport
        ])

        let items = (try? await MKLocalSearch(request: request).start().mapItems) ?? []
        cache[key] = Entry(items: items, date: Date())
        return items
    }

    /// Todos os pontos de interesse de certas categorias num raio, sem texto
    /// (MKLocalPointsOfInterestRequest): plano B quando a busca por texto não acha nada
    func search(categories: [MKPointOfInterestCategory], center: CLLocationCoordinate2D, radius: CLLocationDistance) async -> [MKMapItem] {
        let names = categories.map(\.rawValue).sorted().joined(separator: ",")
        let key = cacheKey(term: "categories:" + names, center: center, radius: radius)
        if let entry = cache[key], Date().timeIntervalSince(entry.date) < cacheValidity {
            return entry.items
        }

        let request = MKLocalPointsOfInterestRequest(center: center, radius: radius)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: categories)

        let items = (try? await MKLocalSearch(request: request).start().mapItems) ?? []
        cache[key] = Entry(items: items, date: Date())
        return items
    }

    /// Centro de um bairro ou região citado pela pessoa ("Higienópolis"), procurando perto dela.
    /// Nil se não encontrar ou se o lugar estiver longe demais (> 100 km).
    func center(ofArea area: String, near reference: CLLocationCoordinate2D) async -> CLLocationCoordinate2D? {
        let key = area.lowercased().trimmingCharacters(in: .whitespaces)
        if let center = areaCenters[key] { return center }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = area
        request.resultTypes = .address
        request.region = MKCoordinateRegion(center: reference,
                                            latitudinalMeters: 50_000,
                                            longitudinalMeters: 50_000)

        guard let item = try? await MKLocalSearch(request: request).start().mapItems.first else { return nil }
        let center = Self.coordinate(of: item)
        let distance = CLLocation(latitude: center.latitude, longitude: center.longitude)
            .distance(from: CLLocation(latitude: reference.latitude, longitude: reference.longitude))
        guard distance < 100_000 else { return nil }

        areaCenters[key] = center
        return center
    }

    /// Termo normalizado + centro arredondado (~100 m) + raio
    private func cacheKey(term: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) -> String {
        let lat = (center.latitude * 1000).rounded() / 1000
        let lon = (center.longitude * 1000).rounded() / 1000
        return "\(term.lowercased().trimmingCharacters(in: .whitespaces))|\(lat)|\(lon)|\(Int(radius))"
    }

    private static func coordinate(of item: MKMapItem) -> CLLocationCoordinate2D {
        if #available(iOS 26, *) {
            return item.location.coordinate
        } else {
            return item.placemark.coordinate
        }
    }
}
