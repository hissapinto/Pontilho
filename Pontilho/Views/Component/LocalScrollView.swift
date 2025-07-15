//
//  LocalScrollView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct LocalScrollView: View {
    var cafes: [Local]

    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Text("A visitar")
                        .bold()
                        .padding(.leading, 10)
                    Spacer()
                }
                ScrollView(.horizontal) {
                    HStack{
                        ForEach(cafes, id: \.id) { i in
                            if i.jaVisitou == true {
                                LocalCard(cafes: i)
                            }
                        }
                    }.padding(.leading, 10)
                }
            }
        }
    }
}

#Preview {
    LocalScrollView(cafes: cafes)
}
