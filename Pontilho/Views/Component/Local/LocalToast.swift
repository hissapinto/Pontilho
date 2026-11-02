//
//  LocalToast.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 30/07/25.
//

import SwiftUI

struct LocalToast: View {
    ///Lista em que o lugar foi salvo: o toast usa a cor dela
    var localType: LocalEnum?
    
    private var color: Color {
        localType?.color ?? .branquinho
    }
    
    var body: some View {
        VStack {
            ZStack {
                if #available(iOS 26.0, *) {
                    Capsule()
                        .frame(width: 175, height: 60)
                        .foregroundColor(.clear)
                        .glassEffect(.regular.tint(color), in: Capsule())
                } else {
                    Capsule()
                        .frame(width: 175, height: 60)
                        .foregroundColor(color)
                        .shadow(color: .gray, radius: 1.5)
                }
                Text("Novo lugar salvo!")
                    .foregroundColor(.pretinho)
            }.font(.headline)
            .accessibilityElement(children: .combine)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1)
        Spacer()
    }
}

#Preview {
    VStack {
        LocalToast(localType: .coffee)
        LocalToast(localType: .restaurant)
    }
}
