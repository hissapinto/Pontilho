//
//  ListaView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI
import Foundation

struct ListaView: View {
    let listas: Lista
    
    var body: some View {
        ZStack{
            Color(listas.color)
                .ignoresSafeArea()
            VStack{
                Text(listas.name)
                    .font(.system(.largeTitle, design: .serif, weight: .heavy))
                    .italic()
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width * 0.925,  height: 1)
                    .foregroundColor(Color.branquinho)
                    .padding(.bottom, 20)
                
                LocalScrollView(listaLocais: cafes)
            }
        }
    }
}

#Preview {
    ListaView(listas:Lista(name: "Café", image: "Cafe", color: .azulzinho, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed commodo,  tellus vitae blandit sollicitudin, purus dui pellentesque felis, sed  consequat est nunc vitae massa.", locais: cafes))
}
