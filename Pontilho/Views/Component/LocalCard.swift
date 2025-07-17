//
//  LocalCard.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct LocalCard: View {
    var local: Local
//    @State var qtdEstrelasCheia: Int = cafes.qtdEstrelasCheias
//    @State var qtdEstrelasMeia: Int = cafes.qtdEstrelasMeias

    var body: some View {
        VStack(spacing: 0){
            
            Image(local.image)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width * 0.72, height: 170)
                .clipped()
                .clipShape(.rect(
                    topLeadingRadius: 10,
                    topTrailingRadius: 10)
                )
            Rectangle()
                .frame(height:1)
                .foregroundColor(Color.pretinho)
            ZStack{
                Rectangle()
                    .frame(height:30)
                    .foregroundColor(Color.branquinho)
                    .clipShape(.rect(
                        bottomLeadingRadius: 10,
                        bottomTrailingRadius: 10)
                    )
                HStack{
                    Text(local.name)
                        .foregroundColor(.pretinho)
                        .font(.subheadline)
                        .padding(.leading, 10)
                    Spacer()
                    
                    //TODO: Código para escolher a quantidade de estrelas e espelhar imagens estrelas
                    if local.jaVisitou == true {
                        HStack{
                            ForEach(0..<local.qtdEstrelasMeias, id: \.self) { i in
                                Image(.estrelaMeia)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                
                            }
                            ForEach(0..<local.qtdEstrelasCheias, id: \.self) { i in
                                Image(.estrelaCheia)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                
                            }
                        }.padding(.trailing, 7)
                    } else {
                        Image(.estrelaVazia)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .padding(.trailing, 7)
                    }
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
    LocalCard(local: Local(id: UUID(), name: "Árvore do Pão", latitude: 0, longitude: 0, image: "CoffeeShop", qtdEstrelasCheias: 4, qtdEstrelasMeias: 1, jaVisitou: true))
}
