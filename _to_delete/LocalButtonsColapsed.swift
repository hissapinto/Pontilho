//
//  LocalButtonsColapsed.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/08/26.
//

import SwiftUI

struct LocalButtonsColapsed: View {
    var vm: MapViewModel
    let generalPadding: CGFloat
    
    var body: some View {
        HStack {
            Button(role: .destructive) {
                vm.ifIsAboutToDelete = true
            } label: {
                ZStack {
                    if #available(iOS 26.0, *) {
                        Circle()
                            .foregroundStyle(.red)
                            .frame(height: 44)
                            .glassEffect()
                    } else {
                        Circle()
                            .foregroundStyle(.red)
                            .frame(height: 44)
                    }
                    Image(systemName: "trash")
                        .foregroundColor(.branquinho)
                }
            }
            
            Button {
                vm.openInMapsCustom()
            } label: {
                ZStack {
                    if #available(iOS 26.0, *) {
                        Circle()
                            .foregroundStyle(.blue)
                            .frame(height: 44)
                            .glassEffect()
                    } else {
                        Circle()
                            .foregroundStyle(.blue)
                            .frame(height: 44)
                    }
                    Image(systemName: "map")
                        .foregroundColor(.branquinho)
                }
            }
        }
        .padding(.leading, generalPadding)
        .padding(.top, 15)
    }
}
