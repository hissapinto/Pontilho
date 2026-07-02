//
//  LocalView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 18/06/26.
//

import SwiftUI
import MapKit
import Foundation

struct LocalView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var vm: MapViewModel
    var local: Local
    let generalPadding: CGFloat = 20
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading){
                
                Text(vm.selectedLocation?.name ?? "Sem nome")
                    .font(.system(.title, design: .serif, weight: .heavy))
                    .padding(.leading, generalPadding)
                
                Text(vm.selectedLocation?.type ?? "Tipo desconhecido")
                    .font(.footnote)
                    .padding(.leading, generalPadding)
                    .bold()
                
                Divider()
                    .padding(.leading, generalPadding)
                    .padding(.trailing, generalPadding)
                
                Text(vm.selectedLocation?.address ?? "Sem endereço")
                    .font(.footnote)
                    .padding(.leading, generalPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                LocalPhoto(local: local)
                    .padding(.leading, generalPadding)
                    .padding(.top, 15)

                HStack {
                    Button(role: .destructive) {
                        vm.ifIsAboutToDelete = true
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 44)
                                .foregroundColor(.pretinho)
                            Image(systemName: "trash")
                                .foregroundColor(.branquinho)
                        }
                    }
                    
                    Button {
                        vm.openInMapsCustom()
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 44)
                                .foregroundColor(.pretinho)
                            Image(systemName: "map")
                                .foregroundColor(.branquinho)
                        }
                    }
                }
                .padding(.leading, generalPadding)
                .padding(.top, 15)

                Spacer()
                
            }
            .padding(.top, 30)
            .directionOrDeleteAlert(vm: vm)
        }
    }
    
}

#Preview {
    let cdViewModel = CDViewModel()
    let vm = MapViewModel(cdViewModel: cdViewModel)

    let context = CoreDataController.shared.viewContext
    let exemplo = Local(context: context)
    exemplo.id = UUID()
    exemplo.name = "Árvore do Pão"
    exemplo.type = "coffee"
    exemplo.address = "Rua Bela Cintra, São Paulo"
    exemplo.latitude = -23.5558
    exemplo.longitude = -46.6396
    exemplo.identifier = ""

    vm.selectedLocation = exemplo

    return LocalView(vm: vm, local: exemplo)
        .environment(cdViewModel)
        .environment(vm)
}
