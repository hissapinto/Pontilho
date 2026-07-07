//
//  LocalPhoto.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 21/06/26.
//

import SwiftUI

struct LocalPhoto: View {
    let local: Local
    
    private var filenames: [String] {
        //Converter de NSet? (sem tipo) para [Photo]
        let photos = (local.photos as? Set<Photo>) ?? []
        //Tranforma do [Photo] para String, descartando os nil 
        return photos.compactMap{ $0.fileName }
    }
    
    var body: some View {
        if !filenames.isEmpty {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(filenames, id: \.self) { file in
                        if let image = ImageStorage.load(file) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 170)
                                .containerRelativeFrame(.horizontal) { width, axis in
                                    width * 0.90
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 13)
                                        .stroke(.pretinho, lineWidth: 1)
                                }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .padding(.leading, 10)
            .padding(.bottom, 10)
            
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
    
    LocalPhoto(local: cdViewModel.createLocal(name: "teste", latitude: 000, longitude: 000, type: "coffee", identifier: "tblbla", address: "Rua do gato preto", grade: "4.5", hour: "segunda: 20:00 - 23:00", photoFiles: nil))
}
