//
//  LocalCard.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct LocalCard: View {
    @State var qtdEstrelasCheia: Int = 4
    @State var qtdEstrelasMeia: Int = 1
    
    var body: some View {
        VStack(spacing: 0){
            
            Image(.coffeeShop)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.72)
                .clipShape(.rect(
                    topLeadingRadius: 10,
                    topTrailingRadius: 10
                ))
            Rectangle()
                .frame(height:1)
                .foregroundColor(Color.pretinho)
            ZStack{
                Rectangle()
                    .frame(height:30)
                    .foregroundColor(Color.branquinho)
                    .clipShape(.rect(
                        bottomLeadingRadius: 10,
                        bottomTrailingRadius: 10
                    ))
                HStack{
                    Text("Árvore do Pão")
                        .foregroundColor(.pretinho)
                        .font(.subheadline)
                        .padding(.leading, 10)
                    Spacer()
                    
                    //TODO: Código para escolher a quantidade de estrelas e espelhar imagens
                    HStack{
                        ForEach(0..<qtdEstrelasMeia, id: \.self) { i in
                            Image(.estrelaMeia)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                                
                        }
                        ForEach(0..<qtdEstrelasCheia, id: \.self) { i in
                            Image(.estrelaCheia)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                                
                        }
                    }.padding(.trailing, 7)
                }
            }
        }
        .foregroundColor(Color.branquinho)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.pretinho, lineWidth: 1))
        .scaledToFit()
        .frame(width: UIScreen.main.bounds.width * 0.72)
    }
}

#Preview {
    LocalCard()
}
