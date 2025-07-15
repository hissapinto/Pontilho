//
//  ListasScrollView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct ListasScrollView: View {
    var listas: [Lista]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack{
                ForEach(listas, id: \.id) { i in
                    ListaCard(lista: i)
                }
            }.padding(.leading, 10)
        }
    }
}

#Preview {
    ListasScrollView(listas: listas)
}
