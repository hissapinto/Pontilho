//
//  SearchButton.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 28/07/25.
//

import Foundation
import SwiftUI
import MapKit

struct SheetButton: View {
    var type: String
    @ObservedObject var cdViewModel = CDViewModel()
    @Binding var placeItem: MKMapItem?

    let localType: LocalEnum
    
    
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
    
    func placeLatitudeUnwrapped() -> Double {
        do {
            return placeItem!.placemark.coordinate.latitude
        } catch {
            print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
        }
    }
    
    func placeLongitudeUnwrapped() -> Double {
        do {
            return placeItem!.placemark.coordinate.longitude
        } catch {
            print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
        }
    }
    
    var body: some View{
        Button {
            let newLocation = cdViewModel.createLocal(name: placeNameUnWrapped(), latitude: placeLatitudeUnwrapped(), longitude: placeLongitudeUnwrapped(), type: type)
            print("ENTROU AQUI")
        } label: {
            ZStack{
                Image(localType.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.height * 0.055)
                    .padding(7)
                    .background{
                        Color(localType.color)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.pretinho, lineWidth: 1)
                    )
            }
        }
    }
    
}

#Preview {
    // Define a coordinate
    let coordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437) // Los Angeles

    // Create an MKPlacemark
    let placemark = MKPlacemark(coordinate: coordinate)

    // Create an MKMapItem from the placemark
    let mapItem = MKMapItem(placemark: placemark)
    
    SheetButton(type: "coffee", placeItem: .constant(mapItem) , localType: .coffee)
}
