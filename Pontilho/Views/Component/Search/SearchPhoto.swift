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
                VStack(alignment: .leading, spacing: 6) {
                    ///"Google Maps" label
                    GoogleMapsLabel()

                    ScrollView(.horizontal) {
                        HStack(alignment: .top) {
                            ForEach(vm.placesPhotos) { photo in
                                VStack(alignment: .leading, spacing: 4) {
                                    Image(uiImage: photo.image)
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

                                    ///Créditos da foto
                                    PhotoCreditText(credits: photo.credits)
                                        .containerRelativeFrame(.horizontal, alignment: .leading) { width, axis in
                                            width * 0.95
                                        }
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .scrollClipDisabled()
                }
                .padding(.leading, 20)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    
                    if vm.placeInfo != nil {
                        GoogleMapsLabel()
                    }

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
