//
//  GoogleAttribution.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/11/26.
//

import SwiftUI

/// Cinza indicado pelo Google para textos de atribuição (#5E5E5E).
private let attributionGray = Color(red: 0x5E / 255, green: 0x5E / 255, blue: 0x5E / 255)

/// Atribuição obrigatória ao exibir dados da Google Places API fora de um Google Map.
/// Texto aceito pelo Google no lugar do logo quando o espaço é limitado:
/// fonte normal, peso 400, tamanho 12, cor #5E5E5E, sem traduzir nem quebrar linha.
struct GoogleMapsLabel: View {
    var body: some View {
        Text(verbatim: "Google Maps")
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(attributionGray)
            .lineLimit(1)
            .fixedSize()
            .accessibilityLabel(Text(verbatim: "Google Maps"))
    }
}

/// Créditos dos autores de uma foto ("Foto: Nome1, Nome2"), com link para o perfil quando houver.
struct PhotoCreditText: View {
    let credits: [PhotoAttribution]

    var body: some View {
        Text(creditsText)
            .font(.caption2)
            .foregroundStyle(attributionGray)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    private var creditsText: AttributedString {
        guard !credits.isEmpty else { return AttributedString(" ") }
        var text = AttributedString("Foto: ")
        for (index, credit) in credits.enumerated() {
            var name = AttributedString(credit.name)
            if let url = credit.url {
                name.link = url
                name.underlineStyle = .single
            }
            text += name
            if index < credits.count - 1 {
                text += AttributedString(", ")
            }
        }
        return text
    }
}

#Preview {
    VStack(alignment: .trailing, spacing: 12) {
        GoogleMapsLabel()
        PhotoCreditText(credits: [
            PhotoAttribution(name: "Maria Souza", url: URL(string: "https://maps.google.com")),
            PhotoAttribution(name: "João Lima", url: nil)
        ])
    }
    .padding()
}
