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
                MapReaderComponent(vm: vm)
            }
            ///UI
            .mapControls {
                MapUserLocationButton()
                MapCompass()
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
