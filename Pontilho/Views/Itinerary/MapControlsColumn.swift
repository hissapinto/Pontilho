//
//  MapControlsColumn.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 02/11/26.
//

import SwiftUI
import MapKit

/// Coluna de controles do mapa: localização, Roteiro do dia e bússola.
/// Fica fora do Map; o `scope` liga os controles da Apple ao mapa certo.
struct MapControlsColumn: View {
    let scope: Namespace.ID
    /// Falso em aparelhos sem Apple Intelligence (o botão some)
    let showsItineraryButton: Bool
    let openItinerary: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            MapUserLocationButton(scope: scope)
            if showsItineraryButton {
                ItineraryButton(action: openItinerary)
            }
            MapCompass(scope: scope)
        }
        .buttonBorderShape(.circle)
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
        .accessibilityLabel("Roteiro do dia")
    }
}

/// Fundo igual ao dos controles da Apple: vidro no iOS 26, material no iOS 18
private struct MapControlBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(.regular.interactive(), in: .circle)
        } else {
            content.background(.regularMaterial, in: Circle())
        }
    }
}

#Preview {
    @Previewable @Namespace var scope
    MapControlsColumn(scope: scope, showsItineraryButton: true) {}
        .tint(.pretinho)
}
