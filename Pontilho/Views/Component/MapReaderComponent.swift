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
    /// Escopo do MapView, para os controles que ficam fora do mapa
    var scope: Namespace.ID? = nil
    
    var body: some View {
        Map(position: $vm.position, selection: $vm.mapSelection, scope: scope) {
            if vm.showPins {
                ForEach(vm.cdViewModel.locais) { item in
                    if vm.typeFilter == item.type {
                        Annotation(item.name ?? "", coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                            LocalPoint(localType: vm.typeFilter)
                                .onTapGesture { openSaved(item) }
                                ///VoiceOver: o ponto vira um botão com o nome do lugar
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(item.name ?? "Lugar salvo")
                                .accessibilityAddTraits(.isButton)
                                .accessibilityHint("Abre o lugar salvo")
                                .accessibilityAction { openSaved(item) }
                        }
                    }
                }
            }
            ForEach(vm.searchResults, id: \.self) { item in
                Annotation(item: item) {
                    SearchPoint()
                        .onTapGesture { openSearchResult(item) }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(item.name ?? "Resultado da busca")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint("Abre os detalhes do lugar")
                        .accessibilityAction { openSearchResult(item) }
                }
            }
        }
        ///Sem controles padrão: localização, ✨ e bússola ficam na coluna do MapView
        .mapControls { }
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

    /// Toque num ponto de lista: abre a sheet do lugar salvo
    private func openSaved(_ item: Local) {
        vm.settingDetent = .localCompacta
        vm.ifselectedLocation = true
        vm.selectedLocation = item
        vm.localToDeleteName = item.name ?? ""
    }

    /// Toque num pin de busca: abre a sheet do resultado
    private func openSearchResult(_ item: MKMapItem) {
        vm.placeItem = item
        vm.showSheet.toggle()
    }
}

#Preview {
    MapReaderComponent(vm: MapViewModel(cdViewModel: CDViewModel()))
}
