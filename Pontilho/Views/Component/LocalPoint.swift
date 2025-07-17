//
//  LocalPoint.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 17/07/25.
//

import SwiftUI
import MapKit

struct LocalPoint: View {
    var cor: UIColor
    
    var body: some View {
            ZStack{
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(cor))
                    .overlay(
                        Circle()
                            .stroke(Color.pretinho, lineWidth: 1)
                    )
                Circle()
                    .frame(width: 12, height: 12)
            }
    }
}

#Preview {
    LocalPoint(cor: .azulzinho)
}
