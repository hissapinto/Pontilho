//
//  MapKitExt.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/08/26.
//

import MapKit

extension MKMapItem {
    var nameUnwrapped: String {
        return name ?? "Nome não encontrado"
    }
    
    var addressUnwrapped: String {
        if #available(iOS 26.0, *) {
            return address?.fullAddress ?? "Sem descrição"
        } else {
            return placemark.title ?? "Sem descrição"
        }
    }
    
    var typeUnwrapped: String {
        let text = pointOfInterestCategory?.rawValue.split(separator: "MKPOICategory")
        return String(text?[0] ?? "Categoria não encontrada")
    }
}

/// ==========================================
/// EXTENSIONS (Extensões)

/// O que são?
/// As Extensions permitem adicionar novas funcionalidades (variáveis ou
/// funções) a tipos que já existem no Swift (como String, MKMapItem, Date),
/// mesmo que você não tenha acesso ao código-fonte original da Apple.

/// Por que usamos aqui?
/// Em vez de o ViewModel ter que "desempacotar" e formatar os dados
/// toda vez, nós ensinamos o próprio objeto (ex: MKMapItem) a fazer isso.

/// Vantagens:
/// 1. Leitura Natural: A sintaxe fica muito mais limpa e fluida (usamos
///    `local.formattedName` em vez de `viewModel.formatName(local)`).
/// 2. Reutilização Global (DRY): Qualquer tela ou ViewModel do aplicativo
///    agora pode usar essas formatações sem precisar duplicar código.
/// 3. Responsabilidade Única: Retira o "trabalho braçal" de manipulação
///    de texto de dentro do ViewModel, deixando-o focado na regra de negócio.
/// ==========================================
