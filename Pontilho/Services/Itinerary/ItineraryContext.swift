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
        /// Lista do Pontilho do lugar (salvo: a lista dele; novo: a que combina com a categoria do MapKit)
        let listType: LocalEnum?
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

    /// Cada busca feita, com o termo e os lugares que ela mostrou (na ordem da pontuação).
    /// Vira um grupo "Sugestões para {termo}" na tela.
    struct SearchGroup {
        let term: String
        let aliases: [String]
    }
    private(set) var searchGroups: [SearchGroup] = []
    private(set) var searchCount = 0
    let searchLimit: Int
    /// "Estou com sorte": a busca devolve UM lugar sorteado entre os 5 melhores
    let isLuckyDraw: Bool
    /// "Estou com sorte" vazio: lista e termo sorteados pelo código (o termo do modelo é ignorado)
    let drawnList: LocalEnum?
    let drawnTerm: String?
    /// Texto que a pessoa digitou: um bairro só vale se aparecer aqui
    let userRequest: String

    init(places: [Local],
         location: CLLocationCoordinate2D?,
         userRequest: String = "",
         searchService: LocalSearchService,
         isLuckyDraw: Bool = false,
         drawnList: LocalEnum? = nil,
         drawnTerm: String? = nil,
         searchLimit: Int? = nil,
         onProgress: @escaping (String) -> Void = { _ in }) {
        self.isLuckyDraw = isLuckyDraw
        self.userRequest = userRequest
        self.drawnList = drawnList
        self.drawnTerm = drawnTerm
        self.searchLimit = searchLimit ?? (isLuckyDraw ? 1 : 3)
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

    /// Sorteia `count` itens sem repetir; o item da posição i (na ordem recebida) pesa (total - i)
    static func weightedSample<T>(_ items: [T], count: Int) -> [T] {
        var remaining = Array(items.enumerated())
        var drawn: [T] = []
        while drawn.count < count, !remaining.isEmpty {
            let weights = remaining.map { Double(items.count - $0.offset) }
            guard let pick = weightedDraw(remaining, weights: weights),
                  let index = remaining.firstIndex(where: { $0.offset == pick.offset }) else { break }
            drawn.append(pick.element)
            remaining.remove(at: index)
        }
        return drawn
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
                             coordinate: saved.coordinate, isSaved: true, listType: saved.type, item: nil)
            lines.append("\(alias) | \(saved.name) | \(category) | \(Self.text(distance: dist)) | salvo")
        }
        return record("savedPlaces()", lines.joined(separator: "\n"))
    }

    // MARK: - Tool 2: busca com região, filtro, pontuação e limite

    /// Busca lugares, pontua e devolve os 5 melhores (nas sugestões soltas, só os que não estão nas listas).
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

        let mentionedArea = Self.mentionedArea(area, in: userRequest)
        if let mentionedArea {
            onProgress("Buscando \(term.lowercased()) perto de \(mentionedArea)…")
        } else {
            onProgress("Buscando \(term.lowercased()) perto de você…")
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
            guard let id = item.identifier?.rawValue else { continue }
            ///Sugestões soltas: só lugares novos. Roteiro: os salvos também podem aparecer
            if isLuckyDraw && savedIDs.contains(id) { continue }
            ///Dentro do raio
            let dist = distance(from: center, to: Self.coordinate(of: item))
            guard dist <= radiusInMeters * 1.2 else { continue }
            candidates.append((id, item, dist, score(item, distance: dist, radius: radiusInMeters, favorites: favorites)))
        }

        ///Roteiro: 5 melhores (cada bloco mostra 3). Sugestões soltas: 8 melhores, para sortear 5
        let best = candidates.sorted { $0.points > $1.points }.prefix(isLuckyDraw ? 8 : 5)
        guard !best.isEmpty else {
            return record(call, "Nenhum lugar encontrado para \(term).")
        }

        ///Sugestões soltas: 5 lugares sorteados entre os 8 melhores, com mais peso para os primeiros
        ///(os mais bem pontuados saem mais, mas a lista muda a cada pesquisa)
        var chosen = Array(best)
        if isLuckyDraw {
            chosen = Self.weightedSample(chosen, count: ItineraryViewModel.singleSearchCount)
        }

        var lines: [String] = []
        var aliases: [String] = []
        for candidate in chosen {
            let name = candidate.item.name ?? "Sem nome"
            let category = Self.category(of: candidate.item)
            ///Salvo: usa a lista dele; novo: a lista que combina com a categoria do MapKit
            let saved = savedPlaces.first { $0.id == candidate.id }
            let alias = show(realID: candidate.id, name: name, category: category,
                             coordinate: Self.coordinate(of: candidate.item), isSaved: saved != nil,
                             listType: saved?.type ?? LocalEnum(category: candidate.item.pointOfInterestCategory),
                             item: candidate.item)
            aliases.append(alias)
            lines.append("\(alias) | \(name) | \(category) | \(Self.text(distance: candidate.distance)) | \(saved != nil ? "salvo" : "novo")")
        }
        searchGroups.append(SearchGroup(term: term, aliases: aliases))
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

    // MARK: - Auxiliares

    /// Guarda o lugar com um apelido curto (reaproveita se ele já foi mostrado)
    private func show(realID: String, name: String, category: String, coordinate: CLLocationCoordinate2D,
                      isSaved: Bool, listType: LocalEnum?, item: MKMapItem?) -> String {
        if let existing = shownPlaces.first(where: { $0.realID == realID }) {
            return existing.alias
        }
        let alias = "L\(shownPlaces.count + 1)"
        shownPlaces.append(ShownPlace(alias: alias, realID: realID, name: name, category: category,
                                      coordinate: coordinate, isSaved: isSaved, listType: listType, item: item))
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

    /// Região citada pela pessoa, ou nil se for vazia, só "aqui perto"
    /// ou se não estiver no que ela digitou (o modelo às vezes inventa ou copia de outro lugar)
    private static func mentionedArea(_ area: String, in request: String) -> String? {
        let text = area.trimmingCharacters(in: .whitespacesAndNewlines)
        let generic = ["", "aqui", "aqui perto", "perto", "perto de mim", "próximo", "proximo", "por perto", "ao redor"]
        guard !generic.contains(text.lowercased()) else { return nil }
        guard normalized(request).contains(normalized(text)) else { return nil }
        return text
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
