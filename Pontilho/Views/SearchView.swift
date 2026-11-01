//
//  EditView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 17/07/25.
//

import SwiftUI
import MapKit
import Foundation

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(CDViewModel.self) private var cdViewModel
    
    @Bindable var vm: MapViewModel
    @State var eVm: SearchViewModel?
    @State var rep = SearchRepository()
    
    var local: MKMapItem
    let generalPadding: CGFloat = 20
    
    var body: some View {
        NavigationStack {
            if let eVm {
                content(eVm: eVm, vm: vm, local: local, generalPadding: generalPadding)
            } else {
                ProgressView()
                    .task {
                        if eVm == nil {
                            eVm = SearchViewModel(repository: rep)
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private func content(eVm: SearchViewModel, vm: MapViewModel, local: MKMapItem, generalPadding: CGFloat) -> some View {
        ///Se o conteúdo não couber na sheet (iPhones menores), ela passa a rolar em vez de cortar o título
        ViewThatFits(in: .vertical) {
            sheetBody(eVm: eVm, vm: vm, local: local, generalPadding: generalPadding)
            ScrollView {
                sheetBody(eVm: eVm, vm: vm, local: local, generalPadding: generalPadding)
            }
        }
        ///performar a cada troca de local
        .task(id: local.identifier?.rawValue) {
            eVm.placesPhotos = [] //limpa
            await eVm.fetchPlacePhotosAndInfo(for: local)
        }
    }
    
    @ViewBuilder
    private func sheetBody(eVm: SearchViewModel, vm: MapViewModel, local: MKMapItem, generalPadding: CGFloat) -> some View {
        VStack(alignment: .leading){
            Text(local.nameUnwrapped)
                .font(.system(.title, design: .serif, weight: .heavy))
                .padding(.leading, generalPadding)
            
            HStack {
                Text(local.typeUnwrapped)
                    .font(.footnote)
                    .padding(.leading, generalPadding)
                    .bold()
                
                Spacer()
                
                Text(eVm.placeInfo?.rating?.asRating ?? "")
                    .font(.footnote)
                    .padding(.trailing, generalPadding)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
                .padding([.leading, .trailing], generalPadding)
            
            Text(local.addressUnwrapped)
                .font(.footnote)
                .padding(.leading, generalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            SearchPhoto(vm: eVm)
                .padding(.top, 6)
                .padding(.bottom, 15)
            
            if vm.settingDetent == .expandida {
                if let hours = eVm.placeInfo?.regularOpeningHour {
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text("Horários:")
                            .font(.footnote)
                            .padding([.leading], generalPadding)
                            .padding(.bottom, 4)
                            .fontWeight(.heavy)
                        
                        ForEach(hours, id: \.self) { h in
                            let t = h.splitString
                            if t.count == 2 {
                                
                                HStack {
                                    Text(t[0])
                                        .font(.footnote)
                                        .padding(.leading, generalPadding)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    Text(t[1])
                                        .font(.footnote)
                                        .padding(.trailing, generalPadding)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                            } else {
                                Text(h)
                                    .font(.footnote)
                                    .padding(.leading, generalPadding)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }.padding(.bottom, generalPadding)
                } else {
                    Text("Sem informações de horários")
                        .font(.footnote)
                        .padding([.leading], generalPadding)
                        .padding(.bottom, 4)
                        .bold()
                }
            }
            
            Spacer()
            
            Text("Salvar em uma lista: ")
                .font(.headline)
                .padding(.leading, generalPadding)
            
            ScrollView(.horizontal) {
                HStack{
                    ForEach(LocalEnum.allCases, id: \.self) { type in
                        SearchSheetButton(type: type.rawValue, placeItem: $vm.placeItem, didLocalWasCreated: $vm.didLocalWasCreated, lastSavedType: $vm.lastSavedType, vm: eVm, localType: type)
                    }
                }
            }.padding(.leading, generalPadding)
        }
        .padding(.top, 30)
    }
}

#Preview {
    let mapItem = MKMapItem(placemark: MKPlacemark(
        coordinate: CLLocationCoordinate2D(latitude: -23.5558, longitude: -46.6396)
    ))
    mapItem.name = "Árvore do Pão"
    mapItem.pointOfInterestCategory = .cafe
    
    let cdViewModel = CDViewModel()
    let vm = MapViewModel(cdViewModel: cdViewModel)
    
    let rep = SearchRepository()
    let searchVM = SearchViewModel(repository: rep)
    vm.placeItem = mapItem
    
    return SearchView(vm: vm, eVm: searchVM, local: mapItem)
        .environment(cdViewModel)
}
