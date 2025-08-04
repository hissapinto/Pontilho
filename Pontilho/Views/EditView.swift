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
    @Binding var didLocalWasCreated: Bool
    let generalPadding: CGFloat = 20
    
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
    
    func placeTypeUnwrapped() -> String {
        if placeItem!.pointOfInterestCategory == nil {
            return "Categoria não encontrada"
        } else {
            let fullText = placeItem!.pointOfInterestCategory!.rawValue
            let text = fullText.split(separator: "MKPOICategory")
            return String(text[0])
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack{
                    Text(placeNameUnWrapped())
                        .font(.system(.title, design: .serif, weight: .heavy))
                        .padding(.leading, generalPadding)
                    Spacer()
                }
                HStack{
                    Text(placeTypeUnwrapped())
                        .font(.footnote)
                        .padding(.leading, generalPadding)
                        .bold()
                    Spacer()
                }
                Divider()
                    .padding(.leading, generalPadding)
                    .padding(.trailing, generalPadding)
                HStack{
                    Text(placeAdressUnwrapped())
                        .font(.footnote)
                        .padding(.leading, generalPadding)
                    Spacer()
                }
                Spacer()
                HStack{
                    Text("Salvar em uma lista: ")
                        .font(.headline)
                        .padding(.leading, generalPadding)
                    Spacer()
                }
                HStack{
                    SheetButton(type: "park", placeItem: $placeItem, didLocalWasCreated: $didLocalWasCreated, localType: .park)
                    SheetButton(type: "coffee", placeItem: $placeItem, didLocalWasCreated: $didLocalWasCreated, localType: .coffee)
                    SheetButton(type: "culture", placeItem: $placeItem, didLocalWasCreated: $didLocalWasCreated, localType: .culture)
                    SheetButton(type: "restaurant", placeItem: $placeItem, didLocalWasCreated: $didLocalWasCreated, localType: .restaurant)
                    SheetButton(type: "sweet", placeItem: $placeItem, didLocalWasCreated: $didLocalWasCreated, localType: .sweet)

                }
            }.padding(.top, 30)
        }
    }
    
}

#Preview {
    MapView()
}
