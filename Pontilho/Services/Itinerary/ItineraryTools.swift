//
//  ItineraryTools.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/11/26.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels

/// Tool 1: perfil de gosto calculado no código (não a lista inteira)
@available(iOS 26, *)
struct SavedPlacesTool: Tool {
    let name = "savedPlaces"
    let description = "Mostra o gosto da pessoa: categorias favoritas e lugares salvos perto, com id."

    @Generable
    struct Arguments {}

    let context: ItineraryContext

    func call(arguments: Arguments) async throws -> String {
        await context.tasteProfile()
    }
}

/// Tool 2: busca lugares novos perto da pessoa ou no bairro citado (MapKit), já filtrados e ordenados
@available(iOS 26, *)
struct SearchPlacesTool: Tool {
    let name = "searchPlaces"
    let description = "Busca lugares reais e novos perto da pessoa ou no bairro citado. Devolve até 5: id | nome | categoria | distância."

    @Generable
    struct Arguments {
        @Guide(description: "Só o tipo de lugar, sem horário. Ex.: café, comida japonesa, sorvete, livraria, parque com lago")
        let term: String

        @Guide(description: "Raio da busca em metros", .range(300...5000))
        let radiusInMeters: Int

        @Guide(description: "Bairro ou região que a pessoa citou. Deixe vazio se ela não citou nenhum lugar")
        let area: String
    }

    let context: ItineraryContext

    func call(arguments: Arguments) async throws -> String {
        await context.searchPlaces(term: arguments.term, radius: arguments.radiusInMeters, area: arguments.area)
    }
}

/// Tool 3: minutos a pé entre dois lugares (MKDirections)
@available(iOS 26, *)
struct TravelTimeTool: Tool {
    let name = "travelTime"
    let description = "Minutos a pé entre dois lugares, usando os ids das outras ferramentas."

    @Generable
    struct Arguments {
        @Guide(description: "Id do lugar de saída")
        let originID: String

        @Guide(description: "Id do lugar de chegada")
        let destinationID: String
    }

    let context: ItineraryContext

    func call(arguments: Arguments) async throws -> String {
        await context.travelTime(from: arguments.originID, to: arguments.destinationID)
    }
}
#endif
