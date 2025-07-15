//
//  LocalScrollView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct LocalScrollView: View {
    var imagens: [UIImage] = [.coffeeShop, .coffeeShop2, .coffeeShop3]

    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Text("A visitar")
                        .bold()
                        .padding(.leading, 10)
                    Spacer()
                }
                //ScrollView
            }
        }
    }
}

#Preview {
    LocalScrollView()
}
