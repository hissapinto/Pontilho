//
//  ListasScrollView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct ListasScrollView: View {
    @Binding var showDetails: Bool
    @Binding var typeFilter: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack{
                ListaButton(showDetails: $showDetails, typeFilter: $typeFilter, localType: LocalEnum.park)
                ListaButton(showDetails: $showDetails, typeFilter: $typeFilter, localType: LocalEnum.coffee)
                ListaButton(showDetails: $showDetails, typeFilter: $typeFilter, localType: LocalEnum.culture)
                ListaButton(showDetails: $showDetails, typeFilter: $typeFilter, localType: LocalEnum.restaurant)
                ListaButton(showDetails: $showDetails, typeFilter: $typeFilter, localType: LocalEnum.sweet)
            }
        }.padding(.leading, 10)
    }
}


#Preview {
    ListasScrollView(showDetails: .constant(false), typeFilter: .constant("coffee"))
}
