//
//  ListaCard.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 14/07/25.
//
import Foundation
import SwiftUI
import MapKit

struct ListaButton: View {
    @Binding var showDetails: Bool
    @Binding var typeFilter: String
    let localType: LocalEnum
    
    var body: some View{
        Button {
            showDetails.toggle()
            typeFilter = localType.rawValue
    } label: {
        ZStack{
            Image(localType.image)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.height * 0.055)
                .padding(7)
                .background{
                    Color(localType.color)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .shadow(color: .gray, radius: 1.5)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 7)
//                        .stroke(Color.pretinho, lineWidth: 2)
//                )
        }
    }
}

}

#Preview {
    
    ListaButton(showDetails: .constant(true), typeFilter: .constant("coffee"), localType: .coffee)
}
