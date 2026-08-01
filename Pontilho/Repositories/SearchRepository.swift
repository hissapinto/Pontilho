//
//  SearchRepository.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/08/26.
//

import MapKit
import SwiftUI

enum SearchRepositoryError: Error {
    case dataNotFound
}

@MainActor
class SearchRepository: SearchRepositoryProtocol {
    private var placesAPI = PlacesAPI()
    
    func fetchPlacePhotosAndInfo(for local: MKMapItem) async throws -> PlaceResults {
        
        guard let (photos, info) = await placesAPI.fetchPhotoAndInfo(for: local) else {
            throw SearchRepositoryError.dataNotFound
        }
        
        return PlaceResults(photos: photos, info: info)
    }
}

/// ==========================================
/// REPOSITORY PATTERN

/// O que é?
/// É uma camada de abstração que atua como um "meio-campo" entre a lógica
/// da tela (ViewModel) e a fonte de dados (neste caso, a API do Google).

/// Qual o papel do Protocolo (SearchRepositoryProtocol)?
/// O protocolo atua como um "contrato de trabalho". O ViewModel não conhece
/// a classe real (SearchRepository), ele apenas exige que quem for contratado
/// cumpra as regras do protocolo. Isso aplica a "Inversão de Dependência".

/// Por que usamos aqui?
/// 1. Desacoplamento: O `SearchViewModel` não faz ideia de como a internet
///    funciona ou como os JSONs são lidos. Ele apenas faz o pedido através
///    do protocolo e o Repositório real que se vire para entregar.

/// 2. Testabilidade (Mocking): Graças ao protocolo, podemos criar um
///    `MockSearchRepository` no futuro para testar
///    o ViewModel sem gastar requisições reais ou precisar de internet.

/// 3. Responsabilidade Única: Mantém o ViewModel leve e focado apenas em
///    preparar os dados (formatar textos, etc) para a interface do SwiftUI.
/// ==========================================
