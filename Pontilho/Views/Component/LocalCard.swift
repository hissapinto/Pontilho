//
//  LocalCard.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 15/07/25.
//

import SwiftUI

struct LocalCard: View {
    var localType: LocalEnum
    let place: Local


    var body: some View {
        VStack(spacing: 0){
            ZStack{
                Rectangle()
                    .frame(height:30)
                    .foregroundColor(Color.branquinho)
                    .clipShape(.rect(
                        bottomLeadingRadius: 10,
                        bottomTrailingRadius: 10)
                    )
                HStack{
                    Text(place.name ?? "Unknown coffee")
                        .foregroundColor(.pretinho)
                        .font(.subheadline)
                        .padding(.leading, 10)
                    Spacer()
                }
            }
        }
        .foregroundColor(Color.branquinho)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.pretinho, lineWidth: 1))
        .scaledToFit()
        .frame(width: UIScreen.main.bounds.width * 0.72)
    }
}

#Preview {
    let cdViewModel = CDViewModel()
    LocalCard(localType: .coffee, place: cdViewModel.createLocal(name: "teste", latitude: 000, longitude: 000, type: "coffee", identifier: "tblbla"))
}
