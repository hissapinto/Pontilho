//
//  EditView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 17/07/25.
//

import SwiftUI
import MapKit
import Foundation

struct EditView: View {
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
                            SheetButton(type: type.rawValue, placeItem: $vm.placeItem, didLocalWasCreated: $vm.didLocalWasCreated, localType: type)
                        }
                    }
                }.padding(.leading, generalPadding)
                
            }
            .padding(.top, 30)
            .task {
                eVm.placesPhotos = [] //limpa
                await eVm.fetchPlacePhotos(for: local, near: vm.userLocation ?? CLLocationCoordinate2D(latitude: -23.5489, longitude: -46.6388))
            }
        }
    }
    
}

#Preview {
    let placemark = MKPlacemark(
        coordinate: CLLocationCoordinate2D(latitude: -23.5558, longitude: -46.6396),
        addressDictionary: [
            "Street": "Rua Bela Cintra",
            "City": "São Paulo"
        ]
    )
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = "Árvore do Pão"
    mapItem.pointOfInterestCategory = .cafe
    
    let vm = MapViewModel()
    vm.placeItem = mapItem
    
    return EditView(vm: vm, local: mapItem)
}
