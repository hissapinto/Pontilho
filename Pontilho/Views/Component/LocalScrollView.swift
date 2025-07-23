//
//  LocalScrollView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct LocalScrollView: View {
    var listaLocais: [Local]
    var paddingHorizontal: CGFloat = 15
    var paddingVertical: CGFloat = 15
    
    var body: some View {
        VStack{
            HStack(){
                Text("A visitar")
                    .bold()
                    .padding(.leading, paddingHorizontal)
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack(spacing: paddingHorizontal){
                    ForEach(listaLocais, id: \.id) { i in
                        if i.jaVisitou == true {
                            LocalCard(local: i)
                        }
                    }
                }.padding(.leading, paddingHorizontal)
            }
            .padding(.bottom, paddingVertical)
            .scrollIndicators(.hidden)
            
            HStack{
                Text("Visitados")
                    .bold()
                    .padding(.leading, paddingHorizontal)
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack(spacing: paddingHorizontal){
                    ForEach(listaLocais, id: \.id) { i in
                        if i.jaVisitou == false {
                            LocalCard(local: i)
                        }
                    }
                }.padding(.leading, paddingHorizontal)
            }
            .padding(.bottom, paddingVertical)
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    LocalScrollView(listaLocais: lista)
}
