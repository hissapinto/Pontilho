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
    let paddingVertical: CGFloat = 15
    let paddingHorizontal: CGFloat = 15
    
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
                    .padding(.bottom, paddingVertical)
                    .padding(.top, -5)
                Text(listas.description)
                    .font(.callout)
                    .padding(.leading, paddingHorizontal)
                    .padding(.trailing, paddingHorizontal)
                    .padding(.bottom, paddingVertical)
                
                LocalScrollView(listaLocais: cafes)
            }
        }
    }
}

#Preview {
    ListaView(listas: .exemploLista)
}
