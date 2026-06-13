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
        Map(position: $vm.position) {
            if vm.showPins {
                ForEach(vm.cdViewModel.locais) { item in
                    if vm.typeFilter == item.type {
                        Annotation(item.name ?? "", coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                            LocalPoint(localType: vm.typeFilter)
                                .onTapGesture{
                                    vm.selectedLocation = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)))
                                    vm.ifselectedLocation = true
                                    vm.localToDelete = item
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
    }
}

#Preview {
    MapReaderComponent(vm: MapViewModel(cdViewModel: CDViewModel()))
}
