//
//  ContentView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 07/08/25.
//

import SwiftUI

struct ContentView: View {
    @State var loading: Bool = true
    
    var body: some View {
        ZStack{
            if loading {
                GifView()
                    .transition(.opacity)
                    .zIndex(2)
            } else {
                MapView()
                    .onAppear{
                        NotificationManagerModel.requirePermissions()
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: loading)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                loading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
