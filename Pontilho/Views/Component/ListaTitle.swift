//
//  ListaTitle.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 16/07/25.
//

import SwiftUI

struct ListaTitle: View {
    var localType: String
    
    var body: some View {
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 7)
                    .frame(width:UIScreen.main.bounds.width * 0.925, height: 40)
                    .foregroundColor(LocalEnum(rawValue: localType)?.color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.pretinho, lineWidth: 1)
                    )
                    .padding(.top, 10)
                Text(LocalEnum(rawValue: localType)?.title ?? "")
                    .padding(.top, 7)
                    .font(.system(.title, design: .serif, weight: .heavy))
                    .italic()
            }
        }
    }
}

#Preview {
    ListaTitle(localType: "coffee")
}
