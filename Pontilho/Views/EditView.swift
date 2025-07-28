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
//    @Binding var selectedLocationLatitude: Double
//    @Binding var selectedLocationLontigude: Double
//    private var selectedLocation: MKPlacemark?

    
    var body: some View {
        NavigationStack {
//            selectedLocation = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: selectedLocationLatitude, longitude: selectedLocationLontigude))
            Text("OI")
//            Form {
//                Section {
//                    TextField("Nome do local: ")//, text: $name)
//                }
//            }
            .navigationTitle("Detalhes")
//            .toolbar {
//                Button("Salvar") {
//                    var newLocal = local
//                    newLocal.id = UUID()
//                    newLocal.name = name
//                    
//                    onSave(newLocal)
//                    dismiss()
//                }
//            }
        }
    }
//    init(local: Local, onSave: @escaping (Local) -> Void) {
//        self.local = local
//        self.onSave = onSave
//        
//        _name = State(initialValue: local.name)
//    }
}

#Preview {
    MapView()
}
