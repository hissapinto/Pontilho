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
    @Binding var placeItem: MKMapItem?    
    
    func placeNameUnWrapped() -> String {
        if placeItem == nil {
            return "Nome não encontrado"
        } else if placeItem!.name == nil {
            return "Nome não encontrado"
        } else {
            return placeItem!.name!
        }
    }
    
    func placeAdressUnwrapped() -> String {
        if placeItem == nil {
            return "Sem descrição"
        } else if placeItem!.placemark.title == nil {
            return "Sem descrição"
        } else {
            return placeItem!.placemark.title!
        }
    }
    
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack{
                    Text(placeAdressUnwrapped())
                        .font(.footnote)
                        .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
                Text("Salvar em uma lista: ")
                HStack{
                    SheetButton(type: "coffee", placeItem: $placeItem, localType: .coffee)
                    SheetButton(type: "park", placeItem: $placeItem, localType: .park)
                    SheetButton(type: "culture", placeItem: $placeItem, localType: .culture)
                    SheetButton(type: "restaurant", placeItem: $placeItem, localType: .restaurant)
                    SheetButton(type: "sweet", placeItem: $placeItem, localType: .sweet)

                }
            }
                .navigationTitle(placeNameUnWrapped())
                .navigationBarTitleDisplayMode(.automatic)
        }
    }
    
}

#Preview {
    MapView()
}
