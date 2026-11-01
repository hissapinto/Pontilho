//
//  PresentationDetentExt.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/11/26.
//

import SwiftUI

extension PresentationDetent {
    
    /// Altura da sheet fechada: 61% da tela, mas nunca menos que 480pt,
    /// para o conteúdo principal caber também em iPhones menores (SE, mini)
    static let compacta = PresentationDetent.custom(CompactaDetent.self)
    
    /// Altura da sheet expandida
    static let expandida = PresentationDetent.fraction(0.91)
}

/// 61% da altura disponível, com mínimo de 480pt (limitado à altura máxima da tela)
struct CompactaDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        min(context.maxDetentValue, max(context.maxDetentValue * 0.61, 480))
    }
}
