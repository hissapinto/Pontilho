////
////  ListasScrollView.swift
////  Pontilho
////
////  Created by Isabela Hissa Pinto on 15/07/25.
////
//
//import SwiftUI
//
//struct ListasScrollView: View {
//    @Binding var showDetails: Bool
//    var listas: [Lista]
//    
//    var body: some View {
//        ScrollView(.horizontal) {
//            HStack{
//                ForEach(listas, id: \.id) { i in
//                    ListaButton(lista: i, showDetails: $showDetails)
//                }
//            }.padding(.leading, 10)
//        }
//    }
//}
//
//#Preview {
//    ListasScrollView(showDetails: .constant(false), listas: listas)
//}
