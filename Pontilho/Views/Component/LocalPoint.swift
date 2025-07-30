//
//  LocalPoint.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 17/07/25.
//

import SwiftUI
import MapKit

struct LocalPoint: View {
    var localType: String

    var body: some View {
        ZStack{
            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(LocalEnum(rawValue: localType)?.color)
                .overlay(
                    Circle()
                        .stroke(Color.pretinho, lineWidth: 0.5)
                )
            Circle()
                .frame(width: 10, height: 10)
            
        }
    }
}

#Preview {
    LocalPoint(localType: "coffee")
}
