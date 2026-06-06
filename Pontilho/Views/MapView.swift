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
    @State private var vm = MapViewModel()
    
    var body: some View {
        NavigationStack{
            ZStack{
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
                .onChange(of: vm.isSearchVisible) {
                    if vm.isSearchVisible {
                        vm.deselectList()
                    }
                }
                .onAppear {
                    vm.requestUserAutorization()
                    vm.cdViewModel.getLocal()
                }
                .onChange(of: vm.searchText) {
                    Task {
                        await vm.peformSearch(for: vm.searchText)
                    }
                    
                    vm.cdViewModel.getLocal()
                    vm.deselectList()
                }
                
                ///Mostrar algo
                .sheet(isPresented: $vm.showSheet) {
                    EditView(vm: vm)
                        .presentationDetents([.height(430)],
                                             selection: $vm.settingDetent)
                }
                .directionOrDeleteAlert(vm: vm)
                ListasTitleEScrollView(vm: vm)
            }

            .overlay(LocalToastOverlay(vm: vm))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Explore sua região")
                            .font(.system(.largeTitle, design: .serif, weight: .heavy))
                            .italic()
                    }
                }
            }
            .background(Color.white.opacity(1))
            .toolbarRole(.editor)
        }
    }
}

#Preview {
    MapView()
}
