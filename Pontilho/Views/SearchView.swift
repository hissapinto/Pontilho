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
    @Bindable var vm: MapViewModel
    var eVm = EditViewModel()
    var local: MKMapItem
    let generalPadding: CGFloat = 20
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading){
                
                Text(eVm.placeNameUnWrapped(for: local))
                    .font(.system(.title, design: .serif, weight: .heavy))
                    .padding(.leading, generalPadding)
                
                Text(eVm.placeTypeUnwrapped(for: local))
                    .font(.footnote)
                    .padding(.leading, generalPadding)
                    .bold()
                
                Divider()
                    .padding(.leading, generalPadding)
                    .padding(.trailing, generalPadding)
                
                Text(eVm.placeAdressUnwrapped(for: local))
                    .font(.footnote)
                    .padding(.leading, generalPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                SearchPhoto(vm: eVm)
                    .padding(.top, 15)
                
                Spacer()
                
                Text("Salvar em uma lista: ")
                    .font(.headline)
                    .padding(.leading, generalPadding)
                
                ScrollView(.horizontal) {
                    HStack{
                        ForEach(LocalEnum.allCases, id: \.self) { type in
                            SearchSheetButton(type: type.rawValue, placeItem: $vm.placeItem, didLocalWasCreated: $vm.didLocalWasCreated, vm: eVm, localType: type)
                        }
                    }
                }.padding(.leading, generalPadding)
            }
            .padding(.top, 30)
            .task {
                eVm.placesPhotos = [] //limpa
                await eVm.fetchPlacePhotos(for: local)
            }
        }
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
    vm.placeItem = mapItem

    return SearchView(vm: vm, local: mapItem)
        .environment(cdViewModel)
        .environment(vm)
}
