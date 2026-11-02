//
//  MapControlsColumn.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 02/11/26.
//

import SwiftUI
import MapKit

/// Coluna de controles do mapa: localização, Pesquisa inteligente, limpar a pesquisa e bússola.
/// Fica fora do Map; o `scope` liga os controles da Apple ao mapa certo.
struct MapControlsColumn: View {
    let scope: Namespace.ID
    /// Falso em aparelhos sem Apple Intelligence (o botão some)
    let showsItineraryButton: Bool
    /// Verdadeiro enquanto há lugares da Pesquisa inteligente no mapa (aparece o botão de limpar)
    var showsClearButton: Bool = false
    let openItinerary: () -> Void
    var clearSmartSearch: () -> Void = {}

    var body: some View {
        VStack(spacing: 8) {
            MapUserLocationButton(scope: scope)
            if showsItineraryButton {
                ItineraryButton(action: openItinerary)
            }
            ///Logo abaixo do ✨: tira os lugares do mapa e limpa a pesquisa
            if showsClearButton {
                ClearSmartSearchButton(action: clearSmartSearch)
                    .transition(.scale.combined(with: .opacity))
            }
            MapCompass(scope: scope)
        }
        .buttonBorderShape(.circle)
        .animation(.snappy, value: showsClearButton)
    }
}

/// Botão ✨ no mesmo formato dos controles do mapa
struct ItineraryButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "sparkles")
                .font(.system(size: 17, weight: .medium))
                .frame(width: 44, height: 44)
        }
        .modifier(MapControlBackground())
        .accessibilityLabel("Pesquisa inteligente")
        .accessibilityHint("Sugere lugares e roteiros perto de você com a Apple Intelligence")
    }
}

/// Botão "x" do mesmo tamanho do ✨, em vidro pretinho com o ícone branquinho
struct ClearSmartSearchButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.branquinho)
                .frame(width: 44, height: 44)
        }
        .modifier(MapControlBackground(tint: .pretinho))
        .accessibilityLabel("Limpar Pesquisa inteligente")
        .accessibilityHint("Tira as sugestões do mapa e apaga a pesquisa")
    }
}

/// Fundo igual ao dos controles da Apple: vidro no iOS 26, material no iOS 18.
/// Com `tint`, o vidro fica colorido (no iOS 18, a cor sólida)
private struct MapControlBackground: ViewModifier {
    var tint: Color? = nil

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(.regular.tint(tint).interactive(), in: .circle)
        } else if let tint {
            content.background(tint, in: Circle())
        } else {
            content.background(.regularMaterial, in: Circle())
        }
    }
}

#Preview {
    @Previewable @Namespace var scope
    MapControlsColumn(scope: scope, showsItineraryButton: true, showsClearButton: true) {}
        .tint(.pretinho)
}
