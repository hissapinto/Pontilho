//
//  Itinerary.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/11/26.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels

/// Saída estruturada do agente "Roteiro do dia".
/// As descrições dos @Guide também orientam o modelo, por isso são curtas e diretas.
@available(iOS 26, *)
@Generable
struct GeneratedItinerary {
    @Guide(description: "Título curto do roteiro, em português")
    let title: String

    @Guide(description: "Paradas na ordem de visita", .maximumCount(4))
    let stops: [GeneratedStop]
}

@available(iOS 26, *)
@Generable
struct GeneratedStop {
    @Guide(description: "Id curto do lugar (ex.: L2), copiado exatamente da ferramenta")
    let placeID: String

    @Guide(description: "Nome do lugar, como veio da ferramenta")
    let name: String

    @Guide(description: "Uma frase curta com o motivo da escolha, falando com a pessoa. Só cite um lugar salvo se ele veio da ferramenta savedPlaces")
    let reason: String

    @Guide(description: "salvo se o lugar já está nas listas da pessoa; novo se veio da busca", .anyOf(["salvo", "novo"]))
    let origin: String
}

/// Classificação do pedido único: 1 lugar ou roteiro
@available(iOS 26, *)
@Generable
struct GeneratedIntent {
    @Guide(description: "lugar se a pessoa quer um só lugar; roteiro se quer duas ou mais atividades ou um passeio", .anyOf(["lugar", "roteiro"]))
    let kind: String
}
#endif
