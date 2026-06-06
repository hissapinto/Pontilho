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
    let generalPadding: CGFloat = 20
    
    func placeNameUnWrapped() -> String {
        if vm.placeItem == nil {
            return "Nome não encontrado"
        } else if vm.placeItem!.name == nil {
            return "Nome não encontrado"
        } else {
            return vm.placeItem!.name!
        }
    }
    
    func placeAdressUnwrapped() -> String {
        if vm.placeItem == nil {
            return "Sem descrição"
        } else if vm.placeItem!.placemark.title == nil {
            return "Sem descrição"
        } else {
            return vm.placeItem!.placemark.title!
        }
    }
    
    func placeTypeUnwrapped() -> String {
        guard let placeItem = vm.placeItem else { return "Categoria não encontrada" }
        guard let category = placeItem.pointOfInterestCategory else { return "Categoria não encontrada" }
        
        let text = category.rawValue.split(separator: "MKPOICategory")
        return String(text[0])
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading){
                
                Text(placeNameUnWrapped())
                    .font(.system(.title, design: .serif, weight: .heavy))
                    .padding(.leading, generalPadding)
                
                Text(placeTypeUnwrapped())
                    .font(.footnote)
                    .padding(.leading, generalPadding)
                    .bold()
                
                Divider()
                    .padding(.leading, generalPadding)
                    .padding(.trailing, generalPadding)
                
                Text(placeAdressUnwrapped())
                    .font(.footnote)
                    .padding(.leading, generalPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                SearchPhoto(vm: vm)
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
                
            }.padding(.top, 30)
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
    
    return EditView(vm: vm)
}
