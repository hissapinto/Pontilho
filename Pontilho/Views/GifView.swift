//
//  GifView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 07/08/25.
//

import SwiftUI

struct GifView: View {
    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            VStack{
                GifImage("GifLoading")
                    .frame(width: 205, height: 205)
                    ///Animação decorativa: o VoiceOver pula
                    .accessibilityHidden(true)
                Text("Pontilho")
                    .font(.system(.largeTitle, design: .serif, weight: .heavy))
                    .padding(.top, 20)
                    .preferredColorScheme(.light)
            }.ignoresSafeArea()
        }
    }
}

#Preview {
    GifView()
}
