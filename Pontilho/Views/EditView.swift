//
//  EditView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 17/07/25.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) var dismiss
//    @State var local: Local
//    @State var name: String
//    var onSave: (Local) -> Void
    
    var body: some View {
        NavigationStack {
            Text("oi")
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
    EditView()//local: .exemploLocal) { _ in }
}
