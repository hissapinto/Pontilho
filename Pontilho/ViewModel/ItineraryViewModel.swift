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

/// Disponibilidade do "Roteiro do dia" (tipo comum, usável também no iOS 18)
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
    let reason: String
    let isNew: Bool
    let category: String
    let coordinate: CLLocationCoordinate2D
}

/// Roteiro já validado, pronto para a UI
struct ItineraryResult {
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
    private(set) var itinerary: ItineraryResult?
    private(set) var singlePlace: ItineraryStop?
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
                return .unavailable(reason: "Para usar o Roteiro do dia, ative a Apple Intelligence em Ajustes › Apple Intelligence e Siri.")
            case .modelNotReady:
                return .unavailable(reason: "A Apple Intelligence ainda está se preparando neste aparelho. Tente de novo em alguns minutos.")
            @unknown default:
                return .unavailable(reason: "O Roteiro do dia não está disponível agora. Tente de novo mais tarde.")
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

    /// Ponto de entrada da UI: decide o fluxo e roda
    func generate(places: [Local], location: CLLocationCoordinate2D?) async {
        guard !isGenerating else { return }
        errorMessage = nil
        guard canGenerate() else { return }
        guard #available(iOS 26, *) else { return }

        itinerary = nil
        singlePlace = nil
        log = []
        let text = request.trimmingCharacters(in: .whitespacesAndNewlines)

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

    // MARK: - Fluxo 1: Montar roteiro (até 4 paradas)

    @available(iOS 26, *)
    private func buildItinerary(request: String, places: [Local], location: CLLocationCoordinate2D?) async {
        progress = "Pensando no roteiro…"
        defer { progress = nil }

        let prompt = """
        Pedido: \(request)
        Agora são \(Self.currentTime()).
        \(await locationDescription(location))
        \(Self.noSavedPlacesNote(places))
        """

        var responseLine: String?
        do {
            let (response, context) = try await withOneRetry {
                ///Sessão e contexto novos a cada tentativa (contexto limpo, contador de buscas zerado)
                let context = self.makeContext(places: places, location: location)
                let session = LanguageModelSession(
                    tools: [SavedPlacesTool(context: context),
                            SearchPlacesTool(context: context),
                            TravelTimeTool(context: context)],
                    instructions: Self.itineraryInstructions
                )
                let response = try await session.respond(to: prompt, generating: GeneratedItinerary.self).content
                return (response, context)
            }
            responseLine = "resposta → " + response.stops.map { "\($0.placeID) (\($0.name))" }.joined(separator: ", ")

            if let result = validate(response, context: context) {
                itinerary = result
            } else {
                errorMessage = "Não encontrei lugares para esse pedido. Tente descrever de outro jeito."
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
        \(await locationDescription(location))
        \(Self.noSavedPlacesNote(places))
        """

        var responseLine: String?
        do {
            let (response, context) = try await withOneRetry {
                ///Só duas tools: não há trajeto com um lugar só
                ///isLuckyDraw: a busca devolve UM lugar sorteado entre os 5 melhores
                let context = self.makeContext(places: places, location: location, isLuckyDraw: true,
                                               drawnList: list, drawnTerm: term)
                let session = LanguageModelSession(
                    tools: [SavedPlacesTool(context: context),
                            SearchPlacesTool(context: context)],
                    instructions: Self.singlePlaceInstructions
                )
                let response = try await session.respond(to: prompt, generating: GeneratedStop.self).content
                return (response, context)
            }
            responseLine = "resposta → \(response.placeID) (\(response.name))"

            ///Precisa ser um lugar novo que veio da busca
            if let place = context.place(id: response.placeID, name: response.name), !place.isSaved {
                singlePlace = stop(from: place, number: 1,
                                   reason: context.trustedReason(response.reason, for: place))
            } else if let place = context.shownPlaces.first(where: { !$0.isSaved }) {
                ///O modelo errou o lugar, mas a busca achou algo: usa o melhor pontuado, com um motivo escrito pelo código
                responseLine? += " → plano B: \(place.alias)"
                singlePlace = stop(from: place, number: 1,
                                   reason: ItineraryContext.fallbackReason(for: place))
            } else {
                errorMessage = "Não achei um lugar novo para isso. Tente outro pedido."
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

    private static let itineraryInstructions = """
    Você monta roteiros curtos de passeio para o app Pontilho.
    Use só lugares que vieram das ferramentas e copie o id exatamente (ex.: L2).
    Primeiro chame savedPlaces. Depois chame searchPlaces uma vez para cada coisa pedida; se a pessoa citar um bairro, coloque-o em area.
    No term, coloque só o tipo de lugar, sem horário.
    Faça uma parada para cada coisa pedida, preferindo lugares parecidos com o gosto da pessoa.
    O motivo é uma frase curta e única para cada lugar: diga o que ele oferece, a partir do nome e da categoria. Não use frases prontas.
    Só diga que lembra um lugar salvo se savedPlaces mostrou esse lugar, e use o nome exato dele.
    Responda em português do Brasil.
    """

    private static let singlePlaceInstructions = """
    Você sugere UM lugar novo para a pessoa conhecer, no app Pontilho.
    Primeiro chame savedPlaces. Depois chame searchPlaces uma vez com o pedido; se a pessoa citar um bairro, coloque-o em area.
    A busca devolve um lugar sorteado: sugira esse lugar, copiando o id exatamente (ex.: L3).
    O motivo é uma frase curta e única: diga o que esse lugar oferece, a partir do nome e da categoria. Não use frases prontas.
    Só diga que lembra um lugar salvo se savedPlaces mostrou esse lugar, e use o nome exato dele.
    Responda em português do Brasil.
    """

    // MARK: - Auxiliares

    /// Contexto das tools, com o progresso ligado à UI
    private func makeContext(places: [Local], location: CLLocationCoordinate2D?,
                             isLuckyDraw: Bool = false, drawnList: LocalEnum? = nil, drawnTerm: String? = nil) -> ItineraryContext {
        let context = ItineraryContext(places: places,
                                       location: location,
                                       searchService: searchService,
                                       isLuckyDraw: isLuckyDraw,
                                       drawnList: drawnList,
                                       drawnTerm: drawnTerm,
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

    /// Tira paradas inventadas ou repetidas, usa o nome real e recalcula se é novo
    @available(iOS 26, *)
    private func validate(_ generated: GeneratedItinerary, context: ItineraryContext) -> ItineraryResult? {
        var stops: [ItineraryStop] = []
        for generatedStop in generated.stops {
            guard let place = context.place(id: generatedStop.placeID, name: generatedStop.name),
                  !stops.contains(where: { $0.id == place.realID }) else { continue }
            stops.append(stop(from: place, number: stops.count + 1,
                              reason: context.trustedReason(generatedStop.reason, for: place)))
        }
        guard !stops.isEmpty else { return nil }
        return ItineraryResult(title: generated.title, stops: stops)
    }

    /// Converte um lugar mostrado pelas tools em parada da UI ("novo" vem do código, não do modelo).
    /// A permanência vem da categoria (o modelo sempre escolhia o mínimo da faixa)
    private func stop(from place: ItineraryContext.ShownPlace, number: Int, reason: String) -> ItineraryStop {
        if !place.isSaved, let item = place.item {
            newItems[place.realID] = item
        }
        return ItineraryStop(id: place.realID,
                             number: number,
                             name: place.name,
                             stayTime: Self.text(minutes: ItineraryContext.stayMinutes(category: place.category)),
                             reason: reason,
                             isNew: !place.isSaved,
                             category: place.category,
                             coordinate: place.coordinate)
    }

    /// Uma linha sobre onde a pessoa está (endereço curto do MapKit)
    @available(iOS 26, *)
    private func locationDescription(_ coordinate: CLLocationCoordinate2D?) async -> String {
        guard let coordinate else {
            return "A localização da pessoa é desconhecida."
        }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if let geocoding = MKReverseGeocodingRequest(location: location),
           let item = try? await geocoding.mapItems.first,
           let address = item.address?.shortAddress {
            return "A pessoa está perto de: \(address)."
        }
        return "A pessoa está na localização atual dela."
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

    /// Aviso no prompt quando não há nada salvo, para o modelo não inventar "lembra um lugar que você salvou"
    private static func noSavedPlacesNote(_ places: [Local]) -> String {
        let hasSavedPlaces = places.contains { !($0.identifier ?? "").isEmpty }
        return hasSavedPlaces ? "" : "A pessoa ainda não tem lugares salvos: não cite nenhum."
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
            return "O Roteiro do dia ainda não entende esse idioma. Tente escrever em português."
        case .exceededContextWindowSize:
            return "O pedido ficou longo demais. Tente algo mais curto."
        default:
            return "Não consegui montar agora. Tente de novo."
        }
    }
}
