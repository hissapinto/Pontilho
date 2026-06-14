//
//  regionSearchButton.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 13/06/26.
//

import SwiftUI

struct RegionSearchButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: action) {
                Text("Pesquisar nesse local?")
                    .font(.caption).bold()
                    .pillBackground()
            }
            Spacer()
        }
    }
}

#Preview {
    RegionSearchButton(action: { print("action") })
}

struct PillBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .glassEffect(.regular, in: Capsule())
                .foregroundColor(.pretinho)
        } else {
            content
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Capsule().fill(.pretinho))
                .foregroundColor(.branquinho)
        }
    }
}

extension View {
    func pillBackground() -> some View {
        modifier(PillBackground())
    }
}
