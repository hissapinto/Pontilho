//
//  LocalButtons.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/08/26.
//

import SwiftUI

struct LocalButtons: View {
    var vm: MapViewModel
    let generalPadding: CGFloat
    
    var body: some View {
        HStack {
            Button(role: .destructive) {
                vm.ifIsAboutToDelete = true
            } label: {
                if #available(iOS 26.0, *) {
                    Text("Deletar")
                        .foregroundColor(.branquinho)
                        .frame(height: 44)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .foregroundStyle(.red)
                                .glassEffect()
                        )
                } else {
                    Text("Deletar")
                        .foregroundColor(.branquinho)
                        .frame(height: 44)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .foregroundStyle(.red)
                        )
                }
            }
            
            Button {
                vm.openInMapsCustom()
            } label: {
                if #available(iOS 26.0, *) {
                    Text("Abrir no Mapas")
                        .foregroundColor(.branquinho)
                        .frame(height: 44)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .foregroundStyle(.blue)
                                .glassEffect()
                        )
                } else {
                    Text("Abrir no Mapas")
                        .foregroundColor(.branquinho)
                        .frame(height: 44)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .foregroundStyle(.blue)
                        )
                }
            }
        }
        .padding(.leading, generalPadding)
        .padding(.top, 15)
    }
}
