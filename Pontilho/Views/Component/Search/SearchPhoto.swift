//
//  SearchPhoto.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 06/06/26.
//

import SwiftUI

struct SearchPhoto: View {
    var vm: SearchViewModel

    ///Fotos no tamanho original (o estado fica no MapViewModel, que também ajusta a sheet)
    var isExpanded: Bool = false
    ///Só amplia com a sheet menor; com os horários à mostra o toque não faz nada
    var canExpand: Bool = true
    ///Pede para ampliar/voltar, informando quanto a sheet precisa crescer
    var onToggle: (CGFloat) -> Void = { _ in }

    ///Altura padrão das fotos (recortadas) e limite das ampliadas
    private let collapsedHeight: CGFloat = 170
    private let maxExpandedHeight: CGFloat = 440

    ///Largura do carrossel; cada foto ocupa 95% e o resto mostra o começo da próxima
    @State private var scrollWidth: CGFloat = UIScreen.main.bounds.width - 20
    private var pageWidth: CGFloat { scrollWidth * 0.95 }

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
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Carregando fotos")
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
                                let size = displaySize(of: photo)

                                VStack(alignment: .leading, spacing: 4) {
                                    Image(uiImage: photo.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: size.width, height: size.height)
                                        .clipShape(RoundedRectangle(cornerRadius: 13))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 13)
                                                .stroke(.pretinho, lineWidth: 1)
                                        }
                                        .contentShape(RoundedRectangle(cornerRadius: 13))
                                        ///Toque amplia todas as fotos (tamanho original) ou volta ao padrão
                                        .onTapGesture {
                                            if canExpand { onToggle(extraHeight) }
                                        }
                                        .accessibilityAddTraits(canExpand ? .isButton : [])
                                        .accessibilityHint(canExpand ? (isExpanded ? "Volta as fotos ao tamanho padrão" : "Mostra as fotos inteiras") : "")
                                        .accessibilityLabel(photoLabel(photo))

                                    ///Créditos da foto
                                    PhotoCreditText(credits: photo.credits)
                                }
                                .frame(width: pageWidth, alignment: .leading)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .scrollClipDisabled()
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.width
                    } action: { width in
                        scrollWidth = width
                    }
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
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Sem fotos deste lugar")
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

    /// Nome da foto no VoiceOver: "Foto 1 de 5"
    private func photoLabel(_ photo: PlacePhoto) -> String {
        let index = (vm.placesPhotos.firstIndex { $0.id == photo.id } ?? 0) + 1
        return "Foto \(index) de \(vm.placesPhotos.count)"
    }

    ///Padrão: largura da página x 170 (recortada). Ampliada: foto inteira na proporção original.
    private func displaySize(of photo: PlacePhoto) -> CGSize {
        isExpanded ? fittedSize(of: photo.image) : CGSize(width: pageWidth, height: collapsedHeight)
    }

    ///Quanto a sheet precisa crescer: a foto ampliada mais alta menos a altura padrão
    private var extraHeight: CGFloat {
        let tallest = vm.placesPhotos.map { fittedSize(of: $0.image).height }.max() ?? collapsedHeight
        return tallest - collapsedHeight
    }

    ///Maior tamanho que cabe na página (e no limite de altura) mantendo a proporção da foto
    private func fittedSize(of image: UIImage) -> CGSize {
        guard image.size.width > 0, image.size.height > 0 else {
            return CGSize(width: pageWidth, height: collapsedHeight)
        }
        let scale = min(pageWidth / image.size.width, maxExpandedHeight / image.size.height)
        return CGSize(width: image.size.width * scale, height: image.size.height * scale)
    }
}

#Preview {
    let rep = SearchRepository()

    SearchPhoto(vm: SearchViewModel(repository: rep))
}
