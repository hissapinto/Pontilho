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
    /// Pesquisa inteligente: disponibilidade do modelo e a sheet da Pesquisa inteligente
    @State private var itineraryVm = ItineraryViewModel()
    @State private var showItinerary = false
    /// Fechou a sheet para mostrar um lugar no mapa: guarda o resultado para quando ela abrir de novo
    @State private var keepItineraryResults = false
    
    var body: some View {
        NavigationStack {
            if let vm {
                content(vm: vm)
            } else {
                ProgressView()
                    .accessibilityLabel("Carregando o mapa")
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
            ///UI: controles numa coluna própria, com o botão da Pesquisa inteligente logo abaixo do de localização
            .overlay(alignment: .topTrailing) {
                MapControlsColumn(scope: mapNamespace,
                                  showsItineraryButton: itineraryVm.availability != .hidden,
                                  showsClearButton: vm.isShowingSmartSearchPlaces,
                                  openItinerary: { showItinerary = true },
                                  clearSmartSearch: {
                    ///Botão "x": os pins somem, a pesquisa volta ao começo e o próprio botão some
                    vm.clearSmartSearchPlaces()
                    itineraryVm.reset()
                    AccessibilityNotification.Announcement("Pesquisa limpa").post()
                })
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
            ///Ao fechar, a Pesquisa inteligente volta ao estado inicial (menos quando fechou para mostrar um pin)
            .sheet(isPresented: $showItinerary, onDismiss: {
                if keepItineraryResults {
                    keepItineraryResults = false
                } else {
                    itineraryVm.reset()
                }
            }) {
                ///A própria SmartSearchView define a altura (cabe no formulário; cresce com resultado)
                SmartSearchView(vm: itineraryVm, location: vm.userLocation ?? CLLocationManager().location?.coordinate,
                                onSelectStop: { stop in
                    ///Toque num card: a sheet desce e o lugar aparece como pin de busca
                    Task {
                        guard let item = await itineraryVm.mapItem(for: stop) else { return }
                        keepItineraryResults = true
                        showItinerary = false
                        vm.showSmartSearchPlaces([item])
                    }
                }, onShowAll: {
                    ///"Ver no mapa": a sheet desce e todas as sugestões aparecem como pins de busca
                    Task {
                        let items = await itineraryVm.allMapItems()
                        guard !items.isEmpty else { return }
                        keepItineraryResults = true
                        showItinerary = false
                        vm.showSmartSearchPlaces(items)
                    }
                })
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
        ///Limpou a Pesquisa inteligente (botão, sheet fechada ou nova pesquisa): os pins dela somem
        .onChange(of: itineraryVm.hasResult) {
            if !itineraryVm.hasResult { vm.clearSmartSearchPlaces() }
        }
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
                        ///VoiceOver: título da tela (aparece no rotor de cabeçalhos)
                        .accessibilityAddTraits(.isHeader)
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
