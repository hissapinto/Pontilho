//
//  SearchPhoto.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 06/06/26.
//

import SwiftUI

struct SearchPhoto: View {
    var vm: SearchViewModel
    
    var body: some View {
        if vm.isLoadingPhoto {
            ZStack {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.pretinho)
                        .symbolEffect(.rotate, options: .speed(1.5))
                    Text("Carregando")
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
            .padding(.leading, 20)
        } else {
            if !vm.placesPhotos.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(vm.placesPhotos.indices, id: \.self) { i in
                            Image(uiImage: vm.placesPhotos[i])
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
            } else {
                ZStack {
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
                .padding(.leading, 20)
            }
            
        }
    }
}

#Preview {
    let rep = SearchRepository()
    
    SearchPhoto(vm: SearchViewModel(repository: rep))
}
