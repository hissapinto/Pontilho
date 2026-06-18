//
//  ListasTitleEScrollView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 05/06/26.
//

import SwiftUI

struct ListasTitleEScrollView: View {
    @Bindable var vm: MapViewModel
    
    var body: some View {
        VStack{
            if vm.showPins {
                ListaTitle(localType: vm.typeFilter)
            }
            Spacer() //if se sheet tiver on desliga a listascrolview
            ListasScrollView(vm: vm)
                .padding(.leading, 20)
        }
    }
}

#Preview {
    ListasTitleEScrollView(vm: MapViewModel(cdViewModel: CDViewModel()))
}
