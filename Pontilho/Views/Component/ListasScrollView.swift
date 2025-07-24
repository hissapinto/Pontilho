//
//  ListasScrollView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct ListasScrollView: View {
    @Binding var showDetails: Bool
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack{
                ListaButton(showDetails: $showDetails, localType: LocalEnum.park)
                ListaButton(showDetails: $showDetails, localType: LocalEnum.coffee)
                ListaButton(showDetails: $showDetails, localType: LocalEnum.culture)
                ListaButton(showDetails: $showDetails, localType: LocalEnum.restaurant)
                ListaButton(showDetails: $showDetails, localType: LocalEnum.sweet)
            }
        }.padding(.leading, 10)
    }
}


#Preview {
    ListasScrollView(showDetails: .constant(false))
}
