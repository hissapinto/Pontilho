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
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .padding(.leading, 10)
        .padding(.bottom, 10)
    }
}


#Preview {
    ListasScrollView(vm: MapViewModel())
}
