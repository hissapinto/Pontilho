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
            HStack {
                Text("Novo lugar salvo!")
                    .foregroundColor(.branquinho)
            }.font(.headline)
                .foregroundColor(.primary)
                .padding([.top,.bottom],20)
                .padding([.leading,.trailing],25)
                .background(.pretinho)
                .clipShape(Capsule())
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1)
        Spacer()
        
    }
}

#Preview {
    LocalToast()
}
