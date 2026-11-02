//
//  ItineraryViewModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/11/26.
//

import Foundation
import SwiftUI
import MapKit
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Disponibilidade da "Pesquisa inteligente" (tipo comum, usável também no iOS 18)
enum ItineraryAvailability: Equatable {
    /// Modelo pronto: mostra a funcionalidade
    case available
    /// Aparelho sem Apple Intelligence (ou iOS < 26): esconde o botão
    case hidden
    /// Botão aparece, mas a sheet abre explicando o motivo
    case unavailable(reason: String)
}

/// Parada já validada, pronta para a UI e o mapa (tipo comum, sem Foundation Models)
struct ItineraryStop: Identifiable {
    /// Id do Apple Maps (o mesmo `identifier` dos lugares salvos)
    let id: String
    let number: Int
    let name: String
    /// Permanência sugerida no lugar, já formatada ("50 min", "1 h 30 min")
    let stayTime: String
    let isNew: Bool
    let category: String
    /// Lista do Pontilho que combina com o lugar (cor do card); nil se nenhuma combina
    let listType: LocalEnum?
    let coordinate: CLLocationCoordinate2D
}

/// Um bloco do resultado: "Sugestões para {coisa pedida}" com seus lugares
struct SuggestionGroup: Identifiable {
    let id = UUID()
    let title: String
    let stops: [ItineraryStop]
}

@Observable
@MainActor
final class ItineraryViewModel {

    private(set) var availability: ItineraryAvailability = .hidden

    // MARK: Entrada
    /// Campo único: vazio = sorteio pelo gosto; "cafeteria aqui perto" = 1 lugar; "museu e jantar" = roteiro
    var request: String = ""

    // MARK: Saída
    /// Mensagem de progresso ("Vendo seu gosto…"); nil quando não está gerando
    private(set) var progress: String?
    /// Resultado: um grupo por coisa pedida (roteiro) ou um grupo só (sorte / uma coisa só)
    private(set) var groups: [SuggestionGroup] = []
    /// O que a pessoa pediu na última pesquisa ("Sugestões para …")
    private(set) var submittedRequest: String = ""

    var hasResult: Bool { !groups.isEmpty }
    private(set) var errorMessage: String?
    /// Itens do MapKit dos lugares novos (para "Salvar na lista" na etapa 6)
    private(set) var newItems: [String: MKMapItem] = [:]
    /// Chamadas das tools e resposta do modelo no último pedido (para depurar)
    private(set) var log: [String] = []

    var isGenerating: Bool { progress != nil }

    /// Busca compartilhada entre pedidos, para aproveitar o cache
    private let searchService = LocalSearchService()
    /// Contexto da última tentativa (de onde sai o registro)
    private var lastContext: ItineraryContext?
    /// Geração em andamento (cancelada se a sheet fechar)
    private var generationTask: Task<Void, Never>?

    init() {
        refreshAvailability()
    }

    // MARK: - Disponibilidade

    /// Consulta o SystemLanguageModel e traduz para o que a UI precisa
    func refreshAvailability() {
        if #available(iOS 26, *) {
            availability = Self.modelAvailability()
        } else {
            availability = .hidden
        }
    }

    @available(iOS 26, *)
    private static func modelAvailability() -> ItineraryAvailability {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .available
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                return .hidden
            case .appleIntelligenceNotEnabled:
                return .unavailable(reason: "Para usar a Pesquisa inteligente, ative a Apple Intelligence em Ajustes › Apple Intelligence e Siri.")
            case .modelNotReady:
                return .unavailable(reason: "A Apple Intelligence ainda está se preparando neste aparelho. Tente de novo em alguns minutos.")
            @unknown default:
                return .unavailable(reason: "A Pesquisa inteligente não está disponível agora. Tente de novo mais tarde.")
            }
        }
    }

    /// Confere a disponibilidade logo antes de gerar; se não der, explica o motivo
    private func canGenerate() -> Bool {
        refreshAvailability()
        switch availability {
        case .available:
            return true
        case .unavailable(let reason):
            errorMessage = reason
        case .hidden:
            errorMessage = "Este aparelho não tem Apple Intelligence."
        }
        return false
    }

    // MARK: - Pedido único: decide entre sorteio, 1 lugar ou roteiro

    /// O que o app vai fazer com o texto atual (para o rótulo e o botão da UI)
    enum Mode: Equatable {
        /// Campo vazio: sorteia um lugar pelo gosto
        case lucky
        /// Pedido claramente de roteiro (regra do código, sem modelo)
        case itinerary
        /// O modelo decide entre 1 lugar e roteiro
        case toDecide
    }

    var expectedMode: Mode {
        let text = request.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return .lucky }
        return Self.clearlyAsksForItinerary(text) ? .itinerary : .toDecide
    }

    /// Ponto de entrada da UI: começa a gerar (a tarefa fica guardada para poder ser cancelada)
    func startGenerating(places: [Local], location: CLLocationCoordinate2D?) {
        guard !isGenerating else { return }
        generationTask = Task { await generate(places: places, location: location) }
    }

    /// MKMapItem de uma parada, para virar pin no mapa:
    /// lugar novo já tem o item da busca; lugar salvo é buscado pelo id do Apple Maps
    func mapItem(for stop: ItineraryStop) async -> MKMapItem? {
        if let item = newItems[stop.id] { return item }
        if let identifier = MKMapItem.Identifier(rawValue: stop.id),
           let item = try? await MKMapItemRequest(mapItemIdentifier: identifier).mapItem {
            return item
        }
        ///Último recurso: um item só com nome e coordenada
        let location = CLLocation(latitude: stop.coordinate.latitude, longitude: stop.coordinate.longitude)
        let item: MKMapItem
        if #available(iOS 26, *) {
            item = MKMapItem(location: location, address: nil)
        } else {
            item = MKMapItem(placemark: MKPlacemark(coordinate: stop.coordinate))
        }
        item.name = stop.name
        return item
    }

    /// Todos os lugares do resultado (sem repetir), para "Ver no mapa"
    func allMapItems() async -> [MKMapItem] {
        var seen = Set<String>()
        var items: [MKMapItem] = []
        for stop in groups.flatMap(\.stops) where !seen.contains(stop.id) {
            seen.insert(stop.id)
            if let item = await mapItem(for: stop) { items.append(item) }
        }
        return items
    }

    /// Sheet fechada ou "Limpar pesquisa": cancela o que estiver gerando e volta tudo ao estado inicial
    func reset() {
        generationTask?.cancel()
        generationTask = nil
        request = ""
        clearResults()
    }

    private func clearResults() {
        progress = nil
        groups = []
        submittedRequest = ""
        errorMessage = nil
        newItems = [:]
        log = []
        lastContext = nil
    }

    /// Decide o fluxo e roda
    private func generate(places: [Local], location: CLLocationCoordinate2D?) async {
        guard !isGenerating else { return }
        errorMessage = nil
        guard canGenerate() else { return }
        guard #available(iOS 26, *) else { return }

        groups = []
        log = []
        let text = request.trimmingCharacters(in: .whitespacesAndNewlines)
        submittedRequest = text

        let wantsItinerary: Bool
        let decision: String
        switch expectedMode {
        case .lucky:
            wantsItinerary = false
            decision = "(decisão: sorteio, campo vazio)"
        case .itinerary:
            wantsItinerary = true
            decision = "(decisão: roteiro, pela regra)"
        case .toDecide:
            progress = "Entendendo seu pedido…"
            wantsItinerary = await modelWantsItinerary(text)
            decision = "(decisão: \(wantsItinerary ? "roteiro" : "1 lugar"), pelo modelo)"
        }

        if wantsItinerary {
            await buildItinerary(request: text, places: places, location: location)
        } else {
            await suggestPlace(request: text, places: places, location: location)
        }
        log.insert(decision, at: 0)

        ///Se a sheet fechou no meio, descarta o que chegou depois
        if Task.isCancelled { clearResults() }
    }

    /// Casos óbvios de roteiro, sem gastar uma chamada ao modelo
    private static func clearlyAsksForItinerary(_ text: String) -> Bool {
        let t = text.lowercased()
        let signals = ["roteiro", "passeio", "depois", "o dia", "dia todo", "dia inteiro", "programação", "programacao"]
        return t.contains(",") || signals.contains { t.contains($0) }
    }

    /// Pergunta curta ao modelo: a pessoa quer 1 lugar ou um roteiro? Se falhar, fica com 1 lugar.
    @available(iOS 26, *)
    private func modelWantsItinerary(_ text: String) async -> Bool {
        let session = LanguageModelSession(instructions: Self.intentInstructions)
        guard let response = try? await session.respond(to: text, generating: GeneratedIntent.self) else { return false }
        return response.content.kind == "roteiro"
    }

    // MARK: - Fluxo 1: Roteiro (um bloco de sugestões por coisa pedida)

    /// Quantas coisas um roteiro pode ter, e quantas sugestões cada uma mostra
    static let maxItineraryParts = 5
    static let suggestionsPerGroup = 3
    /// Quantas sugestões aparecem quando não é roteiro (sorte ou pedido de uma coisa só)
    static let singleSearchCount = 5

    @available(iOS 26, *)
    private func buildItinerary(request: String, places: [Local], location: CLLocationCoordinate2D?) async {
        progress = "Entendendo o roteiro…"
        defer { progress = nil }

        var responseLine: String?
        do {
            ///1. O modelo só separa o pedido em partes ("restaurante", "cafeteria", "sorveteria")
            var parts: [(term: String, area: String)] = try await withOneRetry {
                let session = LanguageModelSession(instructions: Self.partsInstructions)
                let response = try await session.respond(to: request, generating: GeneratedRequestParts.self).content
                return response.parts.map { (term: $0.term, area: $0.area) }
            }
            ///Se o modelo não separou nada, o pedido inteiro vira uma parte só
            if parts.isEmpty { parts = [(term: request, area: "")] }
            parts = Array(parts.prefix(Self.maxItineraryParts))
            responseLine = "partes → " + parts.map { $0.area.isEmpty ? $0.term : "\($0.term) (área: \($0.area))" }.joined(separator: ", ")

            ///2. O código faz uma busca para cada parte, na ordem (perfil de gosto entra na pontuação)
            let context = makeContext(places: places, location: location, request: request,
                                      searchLimit: Self.maxItineraryParts)
            for part in parts {
                if Task.isCancelled { break }
                _ = await context.searchPlaces(term: part.term, radius: 1000, area: part.area)
            }

            ///3. Cada busca vira um bloco "Sugestões para {termo}"
            let result = makeGroups(context: context)
            if result.isEmpty {
                errorMessage = "Não encontrei lugares para esse pedido. Tente descrever de outro jeito."
            } else {
                groups = result
            }
        } catch {
            errorMessage = Self.message(for: error)
        }
        log = (lastContext?.log ?? []) + [responseLine].compactMap { $0 }
    }

    // MARK: - Fluxo 2: 1 lugar novo (sorteio se o pedido estiver vazio)

    @available(iOS 26, *)
    private func suggestPlace(request: String, places: [Local], location: CLLocationCoordinate2D?) async {
        progress = request.isEmpty ? "Procurando uma surpresa…" : "Procurando um lugar…"
        defer { progress = nil }

        ///Sem pedido: o código sorteia a lista (com mais chance para as que a pessoa mais salva) e um termo dela
        let list = request.isEmpty
            ? ItineraryContext(places: places, location: location, searchService: searchService).drawList()
            : nil
        let term = list?.searchTerms.randomElement()
        let prompt = """
        \(request.isEmpty ? "A pessoa não disse o que quer. Busque: \(term ?? "café")." : "Pedido: \(request)")
        Agora são \(Self.currentTime()).
        """

        var responseLine: String?
        do {
            let (response, context) = try await withOneRetry {
                ///Só duas tools: não há trajeto entre sugestões soltas
                ///isLuckyDraw: a busca devolve 3 lugares sorteados entre os 5 melhores
                let context = self.makeContext(places: places, location: location, request: request, isLuckyDraw: true,
                                               drawnList: list, drawnTerm: term)
                let session = LanguageModelSession(
                    tools: [SavedPlacesTool(context: context),
                            SearchPlacesTool(context: context)],
                    instructions: Self.suggestionsInstructions
                )
                let response = try await session.respond(to: prompt, generating: GeneratedSuggestions.self).content
                return (response, context)
            }
            responseLine = "resposta → " + response.stops.map { "\($0.placeID) (\($0.name))" }.joined(separator: ", ")

            ///Só lugares novos que vieram da busca, sem repetir
            var result: [ItineraryStop] = []
            for generated in response.stops {
                guard let place = context.place(id: generated.placeID, name: generated.name), !place.isSaved,
                      !result.contains(where: { $0.id == place.realID }) else { continue }
                result.append(stop(from: place, number: result.count + 1))
            }
            ///O modelo deixou algum de fora: completa com os que a busca mostrou
            for place in context.shownPlaces where !place.isSaved && result.count < Self.singleSearchCount {
                guard !result.contains(where: { $0.id == place.realID }) else { continue }
                responseLine? += " → completou com \(place.alias)"
                result.append(stop(from: place, number: result.count + 1))
            }

            if result.isEmpty {
                errorMessage = "Não achei lugares novos para isso. Tente outro pedido."
            } else {
                groups = [SuggestionGroup(title: request.isEmpty ? "Sugestões" : "Sugestões para “\(request)”",
                                          stops: result)]
            }
        } catch {
            errorMessage = Self.message(for: error)
        }
        log = (lastContext?.log ?? []) + [responseLine].compactMap { $0 }
    }

    // MARK: - Instruções (curtas: o modelo tem contexto pequeno)

    private static let intentInstructions = """
    Classifique pedidos de passeio.
    lugar: a pessoa quer um só lugar, mesmo com detalhes (ex.: café e bolo, pizza com amigos).
    roteiro: a pessoa quer duas ou mais atividades em lugares diferentes, ou um passeio (ex.: museu e jantar, algo para a tarde toda).
    """

    private static let partsInstructions = """
    Separe o pedido de passeio nas coisas que a pessoa quer visitar, na ordem em que ela pediu.
    Em cada parte, coloque só o tipo de lugar, sem horário, e o bairro se ela citou um.
    Ex.: "um café de manhã e depois um parque em Pinheiros" vira: café; parque (área: Pinheiros).
    """

    private static let suggestionsInstructions = """
    Você sugere lugares novos para a pessoa conhecer, no app Pontilho.
    Primeiro chame savedPlaces. Depois chame searchPlaces uma vez com o pedido; se a pessoa citar um bairro, coloque-o em area.
    A busca devolve até 5 lugares: sugira todos, na mesma ordem, copiando os ids exatamente (ex.: L3).
    Responda em português do Brasil.
    """

    // MARK: - Auxiliares

    /// Contexto das tools, com o progresso ligado à UI
    private func makeContext(places: [Local], location: CLLocationCoordinate2D?, request: String,
                             isLuckyDraw: Bool = false, drawnList: LocalEnum? = nil, drawnTerm: String? = nil,
                             searchLimit: Int? = nil) -> ItineraryContext {
        let context = ItineraryContext(places: places,
                                       location: location,
                                       userRequest: request,
                                       searchService: searchService,
                                       isLuckyDraw: isLuckyDraw,
                                       drawnList: drawnList,
                                       drawnTerm: drawnTerm,
                                       searchLimit: searchLimit,
                                       onProgress: { [weak self] text in self?.progress = text })
        lastContext = context
        return context
    }

    /// Se o contexto estourar, tenta mais uma vez com uma sessão nova
    @available(iOS 26, *)
    private func withOneRetry<T>(_ generate: () async throws -> T) async throws -> T {
        do {
            return try await generate()
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            progress = "Tentando de novo…"
            return try await generate()
        }
    }

    /// Uma busca por coisa pedida vira "Sugestões para {termo}" com os lugares mais bem pontuados dela
    private func makeGroups(context: ItineraryContext) -> [SuggestionGroup] {
        context.searchGroups.compactMap { searchGroup in
            let places = searchGroup.aliases
                .compactMap { alias in context.shownPlaces.first { $0.alias == alias } }
                .prefix(Self.suggestionsPerGroup)
            guard !places.isEmpty else { return nil }
            let stops = places.enumerated().map { offset, place in
                stop(from: place, number: offset + 1)
            }
            return SuggestionGroup(title: "Sugestões para \(searchGroup.term)", stops: stops)
        }
    }

    /// Converte um lugar mostrado pelas tools em parada da UI ("novo" vem do código, não do modelo).
    /// A permanência vem da categoria (o modelo sempre escolhia o mínimo da faixa)
    private func stop(from place: ItineraryContext.ShownPlace, number: Int) -> ItineraryStop {
        ///Guarda o item do MapKit para virar pin sem precisar buscar de novo
        if let item = place.item {
            newItems[place.realID] = item
        }
        return ItineraryStop(id: place.realID,
                             number: number,
                             name: place.name,
                             stayTime: Self.text(minutes: ItineraryContext.stayMinutes(category: place.category)),
                             isNew: !place.isSaved,
                             category: place.category,
                             listType: place.listType,
                             coordinate: place.coordinate)
    }

    /// 50 → "50 min"; 90 → "1 h 30 min"; 120 → "2 h"
    private static func text(minutes: Int) -> String {
        let minutes = min(max(minutes, 15), 180)
        let (hours, rest) = (minutes / 60, minutes % 60)
        switch (hours, rest) {
        case (0, _): return "\(rest) min"
        case (_, 0): return "\(hours) h"
        default: return "\(hours) h \(rest) min"
        }
    }

    private static func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    /// Erros do modelo em mensagens amigáveis
    @available(iOS 26, *)
    private static func message(for error: Error) -> String {
        guard let generationError = error as? LanguageModelSession.GenerationError else {
            return "Não consegui montar agora. Tente de novo."
        }
        switch generationError {
        case .guardrailViolation:
            return "Não posso ajudar com esse pedido. Tente descrever o passeio de outro jeito."
        case .unsupportedLanguageOrLocale:
            return "A Pesquisa inteligente ainda não entende esse idioma. Tente escrever em português."
        case .exceededContextWindowSize:
            return "O pedido ficou longo demais. Tente algo mais curto."
        default:
            return "Não consegui montar agora. Tente de novo."
        }
    }
}
