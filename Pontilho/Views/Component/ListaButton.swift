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
    @Bindable var vm: MapViewModel
    let localType: LocalEnum
    
    var body: some View{
        Button {
            vm.selectList(type: localType)
        } label: {
            if #available(iOS 26.0, *) {
                Image(localType.image)
                    .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .padding(12)
                        .glassEffect(.regular.tint(Color(localType.color)), in: Circle())
            } else {
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
            }
        }
    }
    
}

#Preview {
    
    ListaButton(vm: MapViewModel(), localType: .coffee)
}
