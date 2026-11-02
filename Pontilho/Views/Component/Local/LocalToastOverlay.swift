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
                    LocalToast(localType: vm.lastSavedType)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .padding(.top, 10)
                }
                Spacer()
            }
        }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    ///VoiceOver: o toast some em 2 s, então o aviso também é falado
    .onChange(of: vm.didLocalWasCreated) {
        if vm.didLocalWasCreated {
            let list = vm.lastSavedType.map { " em \($0.title)" } ?? ""
            AccessibilityNotification.Announcement("Lugar salvo\(list)").post()
        }
    }
    }
}

#Preview {
    LocalToastOverlay(vm: MapViewModel(cdViewModel: CDViewModel()))
}
