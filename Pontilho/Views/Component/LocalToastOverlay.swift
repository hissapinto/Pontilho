//
//  LocalToastOverlay.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 05/06/26.
//

import SwiftUI

struct LocalToastOverlay: View {
    var vm: MapViewModel
    
    var body: some View {
        ZStack {
            VStack{
                if vm.didLocalWasCreated {
                    LocalToast()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1) // Ensure toast is on top
                        .padding(.top, 10)
                }
                Spacer()
            }
        }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    LocalToastOverlay(vm: MapViewModel(cdViewModel: CDViewModel()))
}
