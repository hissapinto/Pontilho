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
    @Binding var didSendNotification: Bool
    
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
                    Text(placeNameUnWrapped())
                        .font(.system(.title, design: .serif, weight: .heavy))
                        .padding(.leading, 20)
                    Spacer()
                }
                HStack{
                    Text(placeAdressUnwrapped())
                        .font(.footnote)
                        .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
                HStack{
                    Text("Salvar em uma lista: ")
                        .font(.headline)
                        .padding(.leading, 20)
                    Spacer()
                }
                HStack{
                    SheetButton(type: "park", placeItem: $placeItem, didSendNotification: $didSendNotification, localType: .park)
                    SheetButton(type: "coffee", placeItem: $placeItem, didSendNotification: $didSendNotification, localType: .coffee)
                    SheetButton(type: "culture", placeItem: $placeItem, didSendNotification: $didSendNotification, localType: .culture)
                    SheetButton(type: "restaurant", placeItem: $placeItem, didSendNotification: $didSendNotification, localType: .restaurant)
                    SheetButton(type: "sweet", placeItem: $placeItem, didSendNotification: $didSendNotification, localType: .sweet)

                }
            }.padding(.top, 30)
//                .navigationTitle(placeNameUnWrapped())
//                .navigationBarTitleDisplayMode(.automatic)
        }
    }
    
}

#Preview {
    MapView()
}
