//
//  LocalToast.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 30/07/25.
//

import SwiftUI

struct LocalToast: View {
    
    var body: some View {
        VStack {
            ZStack {
                if #available(iOS 26.0, *) {
                    Capsule()
                        .frame(width: 175, height: 60)
                        .foregroundColor(.clear)
                        .glassEffect()
                    Text("Novo lugar salvo!")
                        .foregroundColor(.pretinho)
                } else {
                    Capsule()
                        .frame(width: 175, height: 60)
                        .foregroundColor(.pretinho)
                    Text("Novo lugar salvo!")
                        .foregroundColor(.branquinho)
                }
            }.font(.headline)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1)
        Spacer()
    }
}

#Preview {
    LocalToast()
}
