//
//  ListasScrollView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct ListasScrollView: View {
    @Bindable var vm: MapViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack{
                ForEach(LocalEnum.allCases, id: \.self) { type in
                    Button {
                        vm.selectList(type: type)
                    } label: {
                        ListaButton(localType: type)
                    }
                    ///VoiceOver: diz se a lista está à mostra e o que o toque faz
                    .accessibilityAddTraits(isShowing(type) ? .isSelected : [])
                    .accessibilityHint(isShowing(type) ? "Esconde os lugares desta lista do mapa" : "Mostra no mapa os lugares salvos nesta lista")
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .padding(.leading, 10)
        .padding(.bottom, 10)
    }

    /// Lista que está com os pontos à mostra no mapa
    private func isShowing(_ type: LocalEnum) -> Bool {
        vm.showPins && vm.typeFilter == type.rawValue
    }
}


#Preview {
    ListasScrollView(vm: MapViewModel(cdViewModel: CDViewModel()))
}
