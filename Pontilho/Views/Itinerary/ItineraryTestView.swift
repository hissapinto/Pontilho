//
//  ItineraryTestView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/11/26.
//

import SwiftUI
import MapKit

/// TEMPORÁRIA: testa o ViewModel do Roteiro do dia.
/// Será trocada pela sheet de verdade na etapa 5.
struct ItineraryTestView: View {
    @Bindable var vm: ItineraryViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Teste do Roteiro")
                    .font(.system(.title, design: .serif, weight: .heavy))

                Text("Disponibilidade: \(description(of: vm.availability))")
                    .font(.footnote)

                ///Campo único: o app decide entre sorteio, 1 lugar ou roteiro
                TextField("Ex.: um café e depois um parque", text: $vm.request, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Text(modeText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button(buttonTitle) {
                    Task { await vm.generate(places: places, location: location) }
                }
                .disabled(vm.isGenerating)

                if let progress = vm.progress {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text(progress)
                    }
                }

                if let error = vm.errorMessage {
                    Text(error).foregroundStyle(.red)
                }

                if let itinerary = vm.itinerary {
                    Text(itinerary.title).font(.headline)
                    ForEach(itinerary.stops) { stop in
                        row(stop)
                    }
                }

                if let place = vm.singlePlace {
                    Text("Estou com sorte").font(.headline)
                    row(place)
                }

                ///O que o modelo pediu às tools e o que elas devolveram
                if !vm.log.isEmpty {
                    Text("Registro das ferramentas").font(.headline)
                    ForEach(Array(vm.log.enumerated()), id: \.offset) { _, entry in
                        Text(entry)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding(20)
        }
    }

    private func row(_ stop: ItineraryStop) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(stop.number). \(stop.name)\(stop.isNew ? "  [Novo]" : "")")
                .font(.subheadline.bold())
            Text("\(stop.category) · \(stop.reason)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Label("Permanência sugerida: \(stop.stayTime)", systemImage: "clock")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var modeText: String {
        switch vm.expectedMode {
        case .lucky: return "Campo vazio: vou sortear um lugar pelo seu gosto"
        case .itinerary: return "Vou montar um roteiro"
        case .toDecide: return "Vou sugerir 1 lugar ou montar um roteiro, conforme o pedido"
        }
    }

    private var buttonTitle: String {
        switch vm.expectedMode {
        case .lucky: return "Estou com sorte"
        case .itinerary: return "Montar roteiro"
        case .toDecide: return "Buscar"
        }
    }

    private var places: [Local] { CoreDataController.shared.fetchLocais() }
    private var location: CLLocationCoordinate2D? { CLLocationManager().location?.coordinate }

    private func description(of availability: ItineraryAvailability) -> String {
        switch availability {
        case .available: return "disponível"
        case .hidden: return "escondido (aparelho sem Apple Intelligence)"
        case .unavailable(let reason): return "indisponível — \(reason)"
        }
    }
}

#Preview {
    ItineraryTestView(vm: ItineraryViewModel())
}
