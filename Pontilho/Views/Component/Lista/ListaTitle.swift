//
//  ListaTitle.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 16/07/25.
//

import SwiftUI

struct ListaTitle: View {
    var localType: String
    var padTop: CGFloat = 15
    var padTrai: CGFloat = 60
    
    var body: some View {
        VStack{
            ZStack{
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width:UIScreen.main.bounds.width * 0.80, height: 40)
                        .foregroundColor(LocalEnum(rawValue: localType)?.color)
                        .glassEffect()
                        .padding(.top, padTop+3)
                        .padding(.trailing, padTrai)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width:UIScreen.main.bounds.width * 0.80, height: 40)
                        .foregroundColor(LocalEnum(rawValue: localType)?.color)
                        .shadow(color: .gray, radius: 1.5)
                        .padding(.top, padTop+3)
                        .padding(.trailing, padTrai)
                }
                Text(LocalEnum(rawValue: localType)?.title ?? "")
                    .padding(.top, padTop)
                    .padding(.trailing, padTrai)
                    .font(.system(.title, design: .serif, weight: .heavy))
                    .italic()
                    .foregroundStyle(.pretinho)
            }
            ///VoiceOver: um cabeçalho só, sem o retângulo de fundo
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Lista \(LocalEnum(rawValue: localType)?.title ?? "")")
            .accessibilityAddTraits(.isHeader)
        }
    }
}

#Preview {
    ListaTitle(localType: "coffee")
}
