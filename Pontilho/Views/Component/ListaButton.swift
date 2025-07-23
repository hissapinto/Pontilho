//
//  ListaCard.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 14/07/25.
//

import SwiftUI
import MapKit

struct ListaButton: View {
    var lista: Lista
    
    @Binding var showDetails: Bool
    
    var body: some View{
        Button {
            showDetails.toggle()
             } label: {
            ZStack{
                Image(lista.image!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.height * 0.055)
                    .padding(7)
                    .background{
                        Color(lista.color!)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.pretinho, lineWidth: 1)
                    )
            }
        }
    }
    
}

#Preview {
    ListaButton(lista: Lista(name: "Café", image: "Cafe", color: .azulzinho, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed commodo,  tellus vitae blandit sollicitudin, purus dui pellentesque felis, sed  consequat est nunc vitae massa.", locais: cafes), showDetails: .constant(true))
}
