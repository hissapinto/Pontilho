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
                
                HStack {
                    Text(vm.selectedLocation?.type ?? "Tipo desconhecido")
                        .font(.footnote)
                        .padding(.leading, generalPadding)
                        .bold()
                    
                    Spacer()
                    
                    Text(vm.selectedLocation?.grade ?? "")
                        .font(.footnote)
                        .padding(.trailing, generalPadding)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
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
                
                if vm.settingDetent == .fraction(0.80) {
                    if let hour = local.hour, hour.joinString.count > 1 {
                        let hours = hour.joinString
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
                        }
                    } else {
                        Text("Sem informações de horários")
                            .font(.footnote)
                            .padding([.leading], generalPadding)
                            .padding(.bottom, 4)
                            .bold()
                    }
                    
                    LocalButtons(vm: vm, generalPadding: generalPadding)
                    
                } else {
                    LocalButtonsColapsed(vm: vm, generalPadding: generalPadding)
                }

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
