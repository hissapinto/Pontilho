//
//  MapView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 25/07/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Environment(CDViewModel.self) private var cdViewModel
    @State private var vm: MapViewModel?
    
    /// Escopo do mapa: deixa os controles (localização, bússola) ficarem fora do Map, numa coluna nossa
    @Namespace private var mapNamespace
    /// Roteiro do dia: disponibilidade do modelo e a sheet (por enquanto, a tela de teste)
    @State private var itineraryVm = ItineraryViewModel()
    @State private var showItinerary = false
    
    var body: some View {
        NavigationStack {
            if let vm {
                content(vm: vm)
            } else {
                ProgressView()
                    .task {
                        if vm == nil {
                            vm = MapViewModel(cdViewModel: cdViewModel)
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private func content(vm: MapViewModel) -> some View {
        @Bindable var vm = vm
        ZStack {
            MapReader { proxy in
                MapReaderComponent(vm: vm, scope: mapNamespace)
            }
            ///UI: controles numa coluna própria, com o botão do Roteiro logo abaixo do de localização
            .overlay(alignment: .topTrailing) {
                MapControlsColumn(scope: mapNamespace,
                                  showsItineraryButton: itineraryVm.availability != .hidden) {
                    showItinerary = true
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
            }
            .tint(.pretinho)
            
            ///Performar algo
            .searchable(text: $vm.searchText, isPresented: $vm.isSearchVisible, placement: .automatic, prompt: "pesquisar")
            .onAppear {
                vm.requestUserAutorization()
                vm.cdViewModel.getLocal()
            }
            .onChange(of: vm.isSearchVisible) {
                if vm.isSearchVisible {
                    vm.deselectList()
                }
            }
            .onChange(of: vm.searchText) {
                if vm.searchText.isEmpty {
                    vm.unsetSearchLocallyVisible()
                    vm.resetSearch()
                    vm.deselectList()
                }
            }
            .onSubmit(of: .search) {
                Task {
                    let distance = vm.distanceFromUserToCenter() ?? 0
                    if distance > 1000 {
                        await vm.peformSearchOnVisibleRegion(for: vm.searchText)
                    } else {
                        await vm.peformSearchOnUserLocation(for: vm.searchText)
                    }
                }
                vm.deselectList()
            }
            
            ///Mostrar algo
            .sheet(isPresented: $vm.showSheet, onDismiss: {vm.mapSelection = nil; vm.settingDetent = .compacta; vm.arePhotosExpanded = false }) {
                if let local = vm.placeItem {
                    SearchView(vm: vm, local: local)
                        .presentationDetents(vm.arePhotosExpanded ? [.compactaComFotos] : [.compacta, .expandida],
                                             selection: $vm.settingDetent)
                }
            }
            .sheet(isPresented: $vm.ifselectedLocation, onDismiss: { vm.ifselectedLocation = false; vm.settingDetent = .compacta; vm.arePhotosExpanded = false }) {
                if let local = vm.selectedLocation {
                    LocalView(vm: vm, local: local)
                        .presentationDetents(vm.arePhotosExpanded ? [.localCompactaComFotos] : [.localCompacta, .localExpandida],
                                             selection: $vm.settingDetent)
                }
            }
            .sheet(isPresented: $showItinerary) {
                ItineraryTestView(vm: itineraryVm)
                    .presentationDetents([.medium, .large])
            }
            ListasTitleEScrollView(vm: vm)
            if vm.isSearchLocallyVisible {
                RegionSearchButton(
                    action: {
                        Task { await vm.peformSearchOnVisibleRegion(for: vm.searchText) }
                        vm.unsetSearchLocallyVisible()
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .mapScope(mapNamespace)
        .onAppear { itineraryVm.refreshAvailability() }
        .animation(.easeInOut(duration: 2.0), value: vm.isSearchLocallyVisible)
        .overlay(LocalToastOverlay(vm: vm))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Explore sua região")
                        .font(.system(.largeTitle, design: .serif, weight: .heavy))
                        .italic()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .background(Color.white.opacity(1))
        .toolbarRole(.editor)
    }
}

#Preview {
    MapView().environment(CDViewModel())
}
