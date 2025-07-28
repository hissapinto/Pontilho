//
//  SearchPoint.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 28/07/25.
//

import SwiftUI
import MapKit

struct SearchPoint: View {

    var body: some View {
        ZStack{
            Circle()
                .frame(width: 25, height: 25)
                .foregroundColor(.branquinho)
            Image(systemName: "questionmark.circle")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.pretinho)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    SearchPoint()
}
