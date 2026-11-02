//
//  ItineraryContext.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/11/26.
//

import Foundation
import MapKit

/// Estado e lógica compartilhados pelas tools do "Roteiro do dia" (dados só do MapKit/Core Data).
/// As tools devolvem poucas linhas: o modelo no aparelho tem contexto pequeno.
@MainActor
final class ItineraryContext {

    /// Retrato de um lugar salvo (Core Data)
    struct SavedPlace {
        let id: String
        let name: String
        let type: LocalEnum?
        let coordinate: CLLocationCoordinate2D
    }

    /// Lugar que uma tool mostrou ao modelo, com um apelido curto ("L1").
    /// O modelo pequeno copia "L3" sem errar; o id longo do Apple Maps ele às vezes estraga.
    struct ShownPlace {
        let alias: String
        /// Id do Apple Maps (o mesmo `identifier` dos lugares salvos)
        let realID: String
        let name: String
        let category: String
        let coordinate: CLLocationCoordinate2D
        let isSaved: Bool
        /// Item do MapKit (só para lugares novos)
        let item: MKMapItem?
    }

    static let defaultCenter = CLLocationCoordinate2D(latitude: -23.5489, longitude: -46.6388) // São Paulo

    let savedPlaces: [SavedPlace]
    let location: CLLocationCoordinate2D
    private let searchService: LocalSearchService

    /// Mensagem de progresso para a UI ("Vendo seu gosto…", "Buscando cafés…")
    var onProgress: (String) -> Void

    /// Tudo o que as tools mostraram ao modelo, na ordem (L1, L2…)
    private(set) var shownPlaces: [ShownPlace] = []
    /// Chamadas das tools e o que elas devolveram (para depurar)
    private(set) var log: [String] = []
    private(set) var searchCount = 0
    let searchLimit: Int
    /// "Estou com sorte": a busca devolve UM lugar sorteado entre os 5 melhores
    let isLuckyDraw: Bool
    /// "Estou com sorte" vazio: lista e termo sorteados pelo código (o termo do modelo é ignorado)
    let drawnList: LocalEnum?
    let drawnTerm: String?

    init(places: [Local],
         location: CLLocationCoordinate2D?,
         searchService: LocalSearchService,
         isLuckyDraw: Bool = false,
         drawnList: LocalEnum? = nil,
         drawnTerm: String? = nil,
         onProgress: @escaping (String) -> Void = { _ in }) {
        self.isLuckyDraw = isLuckyDraw
        self.drawnList = drawnList
        self.drawnTerm = drawnTerm
        self.searchLimit = isLuckyDraw ? 1 : 3
        self.savedPlaces = places.compactMap { local in
            guard let id = local.identifier, !id.isEmpty else { return nil }
            return SavedPlace(id: id,
                              name: local.name ?? "Sem nome",
                              type: LocalEnum(rawValue: local.type ?? ""),
                              coordinate: CLLocationCoordinate2D(latitude: local.latitude, longitude: local.longitude))
        }
        self.location = location ?? Self.defaultCenter
        self.searchService = searchService
        self.onProgress = onProgress
    }

    // MARK: - Consultas usadas pelo ViewModel

    /// Acha um lugar pelo apelido ("L2"); se o modelo errou o id, tenta pelo nome.
    /// Nil se o lugar não veio de nenhuma tool (o modelo inventou).
    func place(id: String, name: String = "") -> ShownPlace? {
        let key = id.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if let place = shownPlaces.first(where: { $0.alias == key || $0.realID == id }) {
            return place
        }
        let cleanName = Self.normalized(name)
        guard !cleanName.isEmpty else { return nil }
        return shownPlaces.first { Self.normalized($0.name) == cleanName }
            ?? shownPlaces.first { Self.normalized($0.name).contains(cleanName) || cleanName.contains(Self.normalized($0.name)) }
    }

    /// Confere o motivo escrito pelo modelo: se ele fala de um lugar salvo, o nome desse salvo
    /// tem que ter vindo de savedPlaces. Se não veio (ou é um "Café X"), troca por um motivo do código.
    func trustedReason(_ reason: String, for place: ShownPlace) -> String {
        let text = Self.normalized(reason)
        guard !text.isEmpty else { return Self.fallbackReason(for: place) }

        ///"Café X", "Parque X": exemplo copiado
        if reason.range(of: #"\bX\b"#, options: .regularExpression) != nil {
            return Self.fallbackReason(for: place)
        }
        ///Fala de lugar salvo: precisa citar um salvo que a tool mostrou (e que não seja o próprio lugar)
        if text.contains("salv") {
            let citesRealSavedPlace = shownPlaces.contains { shown in
                shown.isSaved && shown.realID != place.realID && text.contains(Self.normalized(shown.name))
            }
            if !citesRealSavedPlace { return Self.fallbackReason(for: place) }
        }
        return reason
    }

    /// Motivo escrito pelo código, quando o do modelo não é confiável
    static func fallbackReason(for place: ShownPlace) -> String {
        if place.isSaved { return "Um dos seus lugares salvos, no caminho." }
        return place.category == "lugar"
            ? "Um lugar novo perto de você."
            : "Um lugar novo de \(place.category) perto de você."
    }

    /// Categorias das listas, da mais frequente para a menos
    func favoriteCategories() -> [(type: LocalEnum, count: Int)] {
        var counts: [LocalEnum: Int] = [:]
        for saved in savedPlaces {
            if let type = saved.type { counts[type, default: 0] += 1 }
        }
        return counts.map { (type: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    /// Quando a pessoa não pediu nada: sorteia uma lista, com mais chance
    /// para as que ela mais salva (todas têm alguma chance).
    func drawList(hour: Int = Calendar.current.component(.hour, from: Date())) -> LocalEnum {
        let counts = Dictionary(uniqueKeysWithValues: favoriteCategories().map { ($0.type, $0.count) })
        let lists: [LocalEnum] = [.park, .coffee, .culture, .restaurant, .night]
        let weights = lists.map { type -> Double in
            ///Noitada só a partir das 17h
            if type == .night && hour < 17 { return 0 }
            return Double(counts[type, default: 0] + 1)
        }
        return Self.weightedDraw(lists, weights: weights) ?? .coffee
    }

    /// Sorteio com peso: o item i tem chance proporcional a weights[i]
    static func weightedDraw<T>(_ items: [T], weights: [Double]) -> T? {
        let total = weights.reduce(0, +)
        guard !items.isEmpty, items.count == weights.count, total > 0 else { return items.first }
        var drawn = Double.random(in: 0..<total)
        for (item, weight) in zip(items, weights) {
            if drawn < weight { return item }
            drawn -= weight
        }
        return items.last
    }

    // MARK: - Tool 1: perfil de gosto

    /// Perfil curto (até 4 linhas): categorias favoritas + até 3 lugares salvos mais próximos
    func tasteProfile() -> String {
        onProgress("Vendo seu gosto…")
        guard !savedPlaces.isEmpty else {
            return record("savedPlaces()", "sem preferências salvas")
        }

        let favorites = favoriteCategories().prefix(3)
            .map { "\($0.type.title) (\($0.count))" }
            .joined(separator: ", ")
        var lines = ["Categorias favoritas: \(favorites)"]

        ///Só lugares salvos a até 20 km entram como exemplo (as categorias contam todos)
        let nearest = savedPlaces
            .map { ($0, distance(from: location, to: $0.coordinate)) }
            .filter { $0.1 <= 20_000 }
            .sorted { $0.1 < $1.1 }
            .prefix(3)
        for (saved, dist) in nearest {
            let category = saved.type?.title ?? "lugar"
            let alias = show(realID: saved.id, name: saved.name, category: category,
                             coordinate: saved.coordinate, isSaved: true, item: nil)
            lines.append("\(alias) | \(saved.name) | \(category) | \(Self.text(distance: dist)) | salvo")
        }
        return record("savedPlaces()", lines.joined(separator: "\n"))
    }

    // MARK: - Tool 2: busca com região, filtro, pontuação e limite

    /// Busca lugares novos, tira os que já estão nas listas, pontua e devolve os 5 melhores.
    /// `area`: bairro ou região citada pela pessoa; vazio (ou "aqui perto") usa a localização dela.
    func searchPlaces(term modelTerm: String, radius: Int, area: String = "") async -> String {
        let call = "searchPlaces(term: \(modelTerm), radius: \(radius), area: \(area))"
        ///Sorte vazio: vale o termo sorteado pelo código (busca, progresso e motivo falam da mesma coisa).
        ///Senão: "parque à tarde" → "parque", porque o MapKit não entende horários.
        let term = drawnTerm ?? Self.withoutTimeOfDay(modelTerm)
        guard searchCount < searchLimit else {
            return record(call, "Limite de \(searchLimit) buscas atingido. Use os lugares já encontrados.")
        }
        searchCount += 1

        let mentionedArea = Self.mentionedArea(area)
        if let mentionedArea {
            onProgress("Buscando \(term.lowercased()) em \(mentionedArea)…")
        } else {
            onProgress("Buscando \(term.lowercased())…")
        }

        ///Centro da busca: o bairro citado (se o MapKit achar) ou a pessoa
        var center = location
        if let mentionedArea, let areaCenter = await searchService.center(ofArea: mentionedArea, near: location) {
            center = areaCenter
        }

        let radiusInMeters = Double(min(max(radius, 300), 5000))
        var items = await searchService.search(term: term, center: center, radius: radiusInMeters)
        if drawnTerm != nil {
            log.append("(termo do sorteio: \(term))")
        }
        ///Plano B do sorteio: se o texto não achar nada, busca pelas categorias da lista sorteada
        if items.isEmpty, let list = drawnList {
            items = await searchService.search(categories: list.mapKitCategories, center: center, radius: radiusInMeters)
            log.append("(plano B por categorias de \(list.title): \(items.count) lugares)")
        }
        let savedIDs = Set(savedPlaces.map(\.id))
        let favorites = favoriteCategories().map(\.type)

        var candidates: [(id: String, item: MKMapItem, distance: Double, points: Double)] = []
        for item in items {
            ///Filtro: só lugares novos (fora das listas) e dentro do raio
            guard let id = item.identifier?.rawValue, !savedIDs.contains(id) else { continue }
            let dist = distance(from: center, to: Self.coordinate(of: item))
            guard dist <= radiusInMeters * 1.2 else { continue }
            candidates.append((id, item, dist, score(item, distance: dist, radius: radiusInMeters, favorites: favorites)))
        }

        let best = candidates.sorted { $0.points > $1.points }.prefix(5)
        guard !best.isEmpty else {
            return record(call, "Nenhum lugar novo encontrado para \(term).")
        }

        ///Sorte: um só lugar, sorteado com peso 5, 4, 3, 2, 1 (o 1º tem 33% de chance, o 5º tem 7%)
        var chosen = Array(best)
        if isLuckyDraw, let drawn = Self.weightedDraw(chosen, weights: chosen.indices.map { Double(chosen.count - $0) }) {
            chosen = [drawn]
        }

        let lines = chosen.map { candidate in
            let name = candidate.item.name ?? "Sem nome"
            let category = Self.category(of: candidate.item)
            let alias = show(realID: candidate.id, name: name, category: category,
                             coordinate: Self.coordinate(of: candidate.item), isSaved: false, item: candidate.item)
            return "\(alias) | \(name) | \(category) | \(Self.text(distance: candidate.distance)) | novo"
        }
        return record(call, lines.joined(separator: "\n"))
    }

    /// Pontuação simples: categoria do Pontilho + favoritas + telefone/site + proximidade.
    /// (O MapKit não informa nota nem preço, então eles não entram.)
    private func score(_ item: MKMapItem, distance: Double, radius: Double, favorites: [LocalEnum]) -> Double {
        var points = 0.0
        if let type = LocalEnum(category: item.pointOfInterestCategory) {
            points += 1.5                               // é o tipo de lugar do Pontilho (não um táxi ou prédio)
            if let position = favorites.firstIndex(of: type) {
                points += max(1, 3 - Double(position))  // favorita nº1 vale 3, nº2 vale 2, demais 1
            }
        }
        if item.phoneNumber != nil || item.url != nil {
            points += 0.5                               // tem telefone ou site: costuma ser um estabelecimento de verdade
        }
        points += max(0, 2 * (1 - distance / radius))  // até 2 pontos por estar perto
        return points
    }

    // MARK: - Tool 3: tempo de deslocamento

    /// Minutos a pé entre dois lugares mostrados pelas tools (MKDirections; estimativa se a rota falhar)
    @available(iOS 26, *)
    func travelTime(from originID: String, to destinationID: String) async -> String {
        onProgress("Calculando o trajeto…")
        let call = "travelTime(\(originID) → \(destinationID))"
        guard let origin = place(id: originID)?.coordinate else {
            return record(call, "Id desconhecido: \(originID). Use ids como L1, vindos das ferramentas.")
        }
        guard let destination = place(id: destinationID)?.coordinate else {
            return record(call, "Id desconhecido: \(destinationID). Use ids como L1, vindos das ferramentas.")
        }

        let request = MKDirections.Request()
        request.source = MKMapItem(location: CLLocation(latitude: origin.latitude, longitude: origin.longitude), address: nil)
        request.destination = MKMapItem(location: CLLocation(latitude: destination.latitude, longitude: destination.longitude), address: nil)
        request.transportType = .walking

        if let eta = try? await MKDirections(request: request).calculateETA() {
            return record(call, "\(max(1, Int((eta.expectedTravelTime / 60).rounded()))) min a pé")
        }
        ///Sem rota: estimativa pela distância em linha reta (~80 m por minuto)
        let meters = distance(from: origin, to: destination)
        return record(call, "cerca de \(max(1, Int(meters / 80))) min a pé (estimativa)")
    }

    // MARK: - Auxiliares

    /// Guarda o lugar com um apelido curto (reaproveita se ele já foi mostrado)
    private func show(realID: String, name: String, category: String,
                      coordinate: CLLocationCoordinate2D, isSaved: Bool, item: MKMapItem?) -> String {
        if let existing = shownPlaces.first(where: { $0.realID == realID }) {
            return existing.alias
        }
        let alias = "L\(shownPlaces.count + 1)"
        shownPlaces.append(ShownPlace(alias: alias, realID: realID, name: name, category: category,
                                      coordinate: coordinate, isSaved: isSaved, item: item))
        return alias
    }

    /// Anota a chamada no registro e devolve a saída
    private func record(_ call: String, _ output: String) -> String {
        log.append("\(call) →\n\(output)")
        return output
    }

    private func distance(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Double {
        CLLocation(latitude: a.latitude, longitude: a.longitude)
            .distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
    }

    /// Região citada pela pessoa, ou nil se for vazia ou só "aqui perto"
    private static func mentionedArea(_ area: String) -> String? {
        let text = area.trimmingCharacters(in: .whitespacesAndNewlines)
        let generic = ["", "aqui", "aqui perto", "perto", "perto de mim", "próximo", "proximo", "por perto", "ao redor"]
        return generic.contains(text.lowercased()) ? nil : text
    }

    /// Tira horários do termo ("café de manhã" → "café"); se sobrar nada, mantém o original
    private static func withoutTimeOfDay(_ term: String) -> String {
        let timesOfDay = ["pela manhã", "de manhã", "de manha", "pela tarde", "à tarde", "a tarde", "de tarde",
                          "pela noite", "à noite", "a noite", "de noite", "no almoço", "no jantar", "agora", "hoje"]
        var clean = " \(term.lowercased()) "
        for time in timesOfDay {
            clean = clean.replacingOccurrences(of: " \(time) ", with: " ")
        }
        clean = clean.split(separator: " ").joined(separator: " ")
        return clean.isEmpty ? term : clean
    }

    /// Sem maiúsculas e sem acentos, para comparar nomes
    private static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "pt_BR"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func coordinate(of item: MKMapItem) -> CLLocationCoordinate2D {
        if #available(iOS 26, *) {
            return item.location.coordinate
        } else {
            return item.placemark.coordinate
        }
    }

    /// Tempo de permanência sugerido, em minutos, pela categoria do lugar
    static func stayMinutes(category: String) -> Int {
        switch category {
        case "café", "padaria": return 40
        case "restaurante", "mercado": return 75
        case "parque", "praia", "feira", "pista de skate": return 60
        case "trilha", "zoológico": return 120
        case "parque de diversões": return 180
        case "museu", "planetário", "aquário", "centro de eventos": return 90
        case "teatro", "cinema": return 120
        case "casa de shows", "vida noturna", "cervejaria", "vinícola", "destilaria": return 120
        case "ponto histórico", "loja": return 30
        case "biblioteca": return 60
        default: return 45
        }
    }

    static func text(distance: Double) -> String {
        distance < 1000
            ? "\(Int((distance / 10).rounded()) * 10) m"
            : String(format: "%.1f km", distance / 1000).replacingOccurrences(of: ".", with: ",")
    }

    /// Categoria legível em português (para o modelo e para a UI)
    static func category(of item: MKMapItem) -> String {
        switch item.pointOfInterestCategory {
        case .cafe: return "café"
        case .bakery: return "padaria"
        case .restaurant: return "restaurante"
        case .foodMarket: return "mercado"
        case .park, .nationalPark: return "parque"
        case .beach: return "praia"
        case .zoo: return "zoológico"
        case .aquarium: return "aquário"
        case .amusementPark: return "parque de diversões"
        case .hiking: return "trilha"
        case .skatePark: return "pista de skate"
        case .museum: return "museu"
        case .planetarium: return "planetário"
        case .library: return "biblioteca"
        case .theater: return "teatro"
        case .movieTheater: return "cinema"
        case .landmark, .nationalMonument, .castle, .fortress: return "ponto histórico"
        case .conventionCenter: return "centro de eventos"
        case .fairground: return "feira"
        case .musicVenue: return "casa de shows"
        case .nightlife: return "vida noturna"
        case .brewery: return "cervejaria"
        case .winery: return "vinícola"
        case .distillery: return "destilaria"
        case .store: return "loja"
        default: return "lugar"
        }
    }
}
