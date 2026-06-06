//
//  SearchPhoto.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 06/06/26.
//

import SwiftUI

struct SearchPhoto: View {
    let images: [UIImage]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(images.indices, id: \.self) { i in
                    Image(uiImage: images[i])
                        .resizable()
                        .scaledToFill()
                        .frame(height: 170)
                        .containerRelativeFrame(.horizontal) { width, axis in
                            width * 0.95
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .overlay {
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(.pretinho, lineWidth: 1)
                        }
                }
            }
        }
        .padding(.leading, 20)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}

#Preview {
    SearchPhoto(images: [UIImage(named: "CoffeeShop")!, UIImage(named: "CoffeeShop2")!, UIImage(named: "CoffeeShop3")!])
}
