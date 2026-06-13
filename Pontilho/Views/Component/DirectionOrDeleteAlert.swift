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
        
        return self.alert(vm.localToDeleteName, isPresented: $bindVm.ifselectedLocation, actions: {
            Button("Abrir no Mapas") {
                vm.selectedLocation?.openInMaps()
                vm.ifselectedLocation = false
            }
            Button("Cancelar", role: .cancel) {
                vm.ifselectedLocation = false
            }
            Button(role: .destructive) {
                if let local = vm.localToDelete {
                    vm.cdViewModel.deleteLocal(local)
                    vm.cdViewModel.getLocal()
                }
                vm.ifselectedLocation = false
            } label: {
                Text("Deletar da lista")
            }
        })
    }
}
