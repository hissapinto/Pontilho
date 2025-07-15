//
//  ListaCard.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 14/07/25.
//

import SwiftUI

struct ListaCard: View {
    var lista: Lista
    
    var body: some View{
        ZStack{
            Image(lista.image)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.height * 0.055)
                .padding(10)
                .background{
                    Color(lista.color)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.pretinho, lineWidth: 1)
                )
        }
    }
    
}

#Preview {
    ListaCard(lista: Lista(name: "Café", image: "Cafe", color: .azulzinho))
}
