//
//  LocalView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 18/06/26.
//

import SwiftUI
import MapKit
import Foundation

struct LocalView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var vm: MapViewModel
    var local: Local
    let generalPadding: CGFloat = 20

    /// Fotos, nota e horários são buscados ao vivo no Google (não podem ser salvos — termos do Google Places).
    @State private var placeVm = SearchViewModel(repository: SearchRepository())

    var body: some View {
        NavigationStack {
            ///Se o conteúdo não couber na sheet (iPhones menores), ela passa a rolar em vez de cortar o título
            ViewThatFits(in: .vertical) {
                sheetBody
                ScrollView {
                    sheetBody
                }
            }
            .directionOrDeleteAlert(vm: vm)
            ///busca ao vivo a cada troca de local
            .task(id: local.identifier) {
                placeVm.placesPhotos = []
                placeVm.placeInfo = nil
                await placeVm.fetchPlacePhotosAndInfo(for: mapItem(from: local))
            }
        }
    }

    /// Conteúdo da sheet
    private var sheetBody: some View {
        VStack(alignment: .leading){

            Text(vm.selectedLocation?.name ?? "Sem nome")
                .font(.system(.title, design: .serif, weight: .heavy))
                .padding(.leading, generalPadding)

            HStack {
                Text(vm.selectedLocation?.type ?? "Tipo desconhecido")
                    .font(.footnote)
                    .padding(.leading, generalPadding)
                    .bold()

                Spacer()

                Text(placeVm.placeInfo?.rating?.asRating ?? "")
                    .font(.footnote)
                    .padding(.trailing, generalPadding)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()
                .padding(.leading, generalPadding)
                .padding(.trailing, generalPadding)

            Text(vm.selectedLocation?.address ?? "Sem endereço")
                .font(.footnote)
                .padding(.leading, generalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            ///Toque nas fotos: ampliam/voltam (só com a sheet menor)
            SearchPhoto(vm: placeVm,
                        isExpanded: vm.arePhotosExpanded,
                        canExpand: vm.settingDetent == .localCompacta || vm.arePhotosExpanded) { extra in
                vm.togglePhotosExpanded(extraHeight: extra, compact: .localCompacta, withPhotos: .localCompactaComFotos)
            }
                .padding([.top, .bottom], 15)

            if vm.settingDetent == .localExpandida {
                if let hours = placeVm.placeInfo?.regularOpeningHour, !hours.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {

                        Text("Horários:")
                            .font(.footnote)
                            .padding([.leading], generalPadding)
                            .padding(.bottom, 4)
                            .fontWeight(.heavy)

                        ForEach(hours, id: \.self) { h in
                            let t = h.splitString
                            if t.count == 2 {

                                HStack {
                                    Text(t[0])
                                        .font(.footnote)
                                        .padding(.leading, generalPadding)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    Text(t[1])
                                        .font(.footnote)
                                        .padding(.trailing, generalPadding)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                            } else {
                                Text(h)
                                    .font(.footnote)
                                    .padding(.leading, generalPadding)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                } else {
                    Text("Sem informações de horários")
                        .font(.footnote)
                        .padding([.leading], generalPadding)
                        .padding(.bottom, 4)
                        .bold()
                }

            }

            Spacer()

            ///Ações no rodapé (mesmo lugar do "Salvar em uma lista" da busca): não pulam quando a sheet muda de altura
            LocalButtons(vm: vm, generalPadding: generalPadding, isExpanded: vm.settingDetent == .localExpandida)

        }
        .padding(.top, 30)
        .animation(.snappy, value: vm.settingDetent == .localExpandida)
    }

    /// Monta um MKMapItem a partir do nome e da coordenada salvos (dados da Apple, não do Google).
    private func mapItem(from local: Local) -> MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: local.latitude, longitude: local.longitude)
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        item.name = local.name
        return item
    }
}

#Preview {
    let cdViewModel = CDViewModel()
    let vm = MapViewModel(cdViewModel: cdViewModel)

    let context = CoreDataController.shared.viewContext
    let exemplo = Local(context: context)
    exemplo.id = UUID()
    exemplo.name = "Árvore do Pão"
    exemplo.type = "coffee"
    exemplo.address = "Rua Bela Cintra, São Paulo"
    exemplo.latitude = -23.5558
    exemplo.longitude = -46.6396
    exemplo.identifier = ""

    vm.selectedLocation = exemplo

    return LocalView(vm: vm, local: exemplo)
        .environment(cdViewModel)
        .environment(vm)
}
