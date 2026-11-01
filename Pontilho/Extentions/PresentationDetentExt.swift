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
    
    /// LocalView (lugar salvo) tem menos conteúdo que a busca, então usa alturas menores
    static let localCompacta = PresentationDetent.custom(LocalCompactaDetent.self)
    static let localExpandida = PresentationDetent.fraction(0.82)
    
    /// Sheet fechada + o espaço extra das fotos ampliadas (busca e lugar salvo)
    static let compactaComFotos = PresentationDetent.custom(CompactaComFotosDetent.self)
    static let localCompactaComFotos = PresentationDetent.custom(LocalCompactaComFotosDetent.self)
}

/// 61% da altura disponível, com mínimo de 480pt (limitado à altura máxima da tela)
struct CompactaDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        min(context.maxDetentValue, max(context.maxDetentValue * 0.61, 480))
    }
}

/// LocalView fechada: 55% da altura disponível, com mínimo de 450pt (limitado à altura máxima da tela)
struct LocalCompactaDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        min(context.maxDetentValue, max(context.maxDetentValue * 0.55, 450))
    }
}

/// Quanto a sheet precisa crescer para as fotos ampliadas caberem (definido antes de ampliar)
enum ExpandedPhotos {
    nonisolated(unsafe) static var extraHeight: CGFloat = 0
}

/// Busca com fotos ampliadas: altura fechada + espaço extra das fotos
struct CompactaComFotosDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let base = CompactaDetent.height(in: context) ?? 0
        return min(context.maxDetentValue, base + ExpandedPhotos.extraHeight)
    }
}

/// Lugar salvo com fotos ampliadas: altura fechada + espaço extra das fotos
struct LocalCompactaComFotosDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        let base = LocalCompactaDetent.height(in: context) ?? 0
        return min(context.maxDetentValue, base + ExpandedPhotos.extraHeight)
    }
}
