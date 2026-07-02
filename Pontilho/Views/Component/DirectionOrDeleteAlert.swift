//
//  DirectionOrDeleteAlert.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 05/06/26.
//

import SwiftUI
import MapKit

extension View {
    func directionOrDeleteAlert(vm: MapViewModel) -> some View {
        @Bindable var bindVm = vm
        
        return self.alert(vm.localToDeleteName, isPresented: $bindVm.ifIsAboutToDelete, actions: {
//            Button("Abrir no Mapas") {
//                vm.openInMapsCustom()
//                vm.ifselectedLocation = false
//            }
            Button("Cancelar", role: .cancel) {
                vm.ifIsAboutToDelete = false
            }
            Button(role: .destructive) {
                if let local = vm.selectedLocation {
                    vm.cdViewModel.deleteLocal(local)
                    vm.cdViewModel.getLocal()
                }
                vm.ifIsAboutToDelete = false
                vm.ifselectedLocation = false
            } label: {
                Text("Deletar da lista")
            }
        })
    }
}
