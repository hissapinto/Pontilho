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
            Image("Cafe")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.height * 0.15)
        }
    }
    
}

#Preview {
    ListaCard(lista: Lista(name: "Café", image: "Cafe", color: .azulzinho))
}
