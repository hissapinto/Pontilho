//
//  MapReaderComponent.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 05/06/26.
//

import SwiftUI
import MapKit

struct MapReaderComponent: View {
    @Bindable var vm: MapViewModel
    
    var body: some View {
        Map(position: $vm.position, selection: $vm.mapSelection) {
            if vm.showPins {
                ForEach(vm.cdViewModel.locais) { item in
                    if vm.typeFilter == item.type {
                        Annotation(item.name ?? "", coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                            LocalPoint(localType: vm.typeFilter)
                                .onTapGesture{
                                    vm.settingDetent = .localCompacta
                                    vm.ifselectedLocation = true
                                    vm.selectedLocation = item
                                    vm.localToDeleteName = item.name!
                                }
                        }
                    }
                }
            }
            ForEach(vm.searchResults, id: \.self) { item in
                Annotation(item: item) {
                    SearchPoint()
                        .onTapGesture {
                            vm.placeItem = item
                            vm.showSheet.toggle()
                        }
                }
            }
        }
        .onMapCameraChange { context in
            
            vm.previousVisibleRegion = vm.visibleRegion
            vm.visibleRegion = context.region
            
            //movimento de camera, e nao de usuário
            if vm.isLikelyProgrammaticMove() || !vm.hasSearchedAtLeastOnce { return }
            
            guard let distance = vm.distanceFromPreviousAndActualVisibleRegion() else { return }
            if distance > 1000 && vm.isSearchVisible && vm.searchText != "" {
                vm.setSearchLocallyVisible()
            }
        }
        .onChange(of: vm.mapSelection) {
            if let item = vm.mapSelection?.value {
                vm.placeItem = item
                vm.showSheet = true
            } else if let feature = vm.mapSelection?.feature {
                Task {
                    let request = MKMapItemRequest(feature: feature)
                    do {
                        let item = try await request.mapItem
                        vm.placeItem = item
                        vm.showSheet = true
                    } catch {
                        return
                    }
                }
            }
        }
    }
}

#Preview {
    MapReaderComponent(vm: MapViewModel(cdViewModel: CDViewModel()))
}
