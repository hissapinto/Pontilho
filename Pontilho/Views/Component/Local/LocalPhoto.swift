//
//  LocalPhoto.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 21/06/26.
//

import SwiftUI

struct LocalPhoto: View {
    let local: Local
    
    var body: some View {
        if local.photoFile != nil {
            Image(uiImage: ImageStorage.load(local.photoFile!)!)
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
        } else {
            ZStack(alignment: .center) {
                VStack(spacing: 8) {
                    Image(systemName: "photo.trianglebadge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(.pretinho)
                    Text("Sem imagem")
                        .font(.caption)
                }
                RoundedRectangle(cornerRadius: 13)
                    .stroke(.pretinho, lineWidth: 1)
                    .foregroundStyle(.branquinho)
                    .frame(height: 170)
                    .containerRelativeFrame(.horizontal) { width, axis in
                        width * 0.90
                    }
            }
        }
    }
}

#Preview {
    let cdViewModel = CDViewModel()
    
    LocalPhoto(local: cdViewModel.createLocal(name: "teste", latitude: 000, longitude: 000, type: "coffee", identifier: "tblbla", address: "Rua do gato preto", photoFile: nil))
}
