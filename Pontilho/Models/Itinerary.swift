//
//  Itinerary.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/11/26.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels

/// Roteiro: o pedido separado nas coisas que a pessoa quer, na ordem.
/// O código faz uma busca para cada parte (mais confiável que deixar o modelo chamar as buscas).
@available(iOS 26, *)
@Generable
struct GeneratedRequestParts {
    @Guide(description: "Cada coisa que a pessoa quer visitar, na ordem do pedido", .maximumCount(5))
    let parts: [GeneratedPart]
}

@available(iOS 26, *)
@Generable
struct GeneratedPart {
    @Guide(description: "Só o tipo de lugar, sem horário. Ex.: restaurante, cafeteria, sorveteria, parque")
    let term: String

    @Guide(description: "Bairro ou região que a pessoa citou para esta parte. Deixe vazio se ela não citou")
    let area: String
}

@available(iOS 26, *)
@Generable
struct GeneratedStop {
    @Guide(description: "Id curto do lugar (ex.: L2), copiado exatamente da ferramenta")
    let placeID: String

    @Guide(description: "Nome do lugar, como veio da ferramenta")
    let name: String
}

/// Sugestões soltas (sem roteiro): até 5 lugares novos
@available(iOS 26, *)
@Generable
struct GeneratedSuggestions {
    @Guide(description: "Os lugares sugeridos, na ordem em que vieram da busca", .maximumCount(5))
    let stops: [GeneratedStop]
}

/// Classificação do pedido único: 1 lugar ou roteiro
@available(iOS 26, *)
@Generable
struct GeneratedIntent {
    @Guide(description: "lugar se a pessoa quer um só lugar; roteiro se quer duas ou mais atividades ou um passeio", .anyOf(["lugar", "roteiro"]))
    let kind: String
}
#endif
