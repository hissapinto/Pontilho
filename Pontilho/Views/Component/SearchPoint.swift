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
        if #available(iOS 26.0, *) {
            Image(.pin)
                .resizable()
                .scaledToFit()
                .frame(width: 25,height: 20)
                .foregroundColor(.pretinho)
                .fontWeight(.semibold)
                .glassEffect()
        } else {
            Image(.pin)
                .resizable()
                .scaledToFit()
                .frame(width: 25,height: 20)
                .foregroundColor(.pretinho)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    SearchPoint()
}
