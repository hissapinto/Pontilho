//
//  LocalButtons.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/08/26.
//

import SwiftUI

/// Ações de um lugar salvo. Com a sheet fechada mostra só os ícones;
/// expandida, o texto aparece ao lado com animação.
struct LocalButtons: View {
    var vm: MapViewModel
    let generalPadding: CGFloat
    let isExpanded: Bool

    var body: some View {
        HStack(spacing: 12) {
            LocalActionButton(title: "Abrir no Mapas",
                              systemImage: "map",
                              tint: .azulzinho,
                              hint: "Abre o lugar no app Mapas",
                              isExpanded: isExpanded) {
                vm.openInMapsCustom()
            }

            ///A confirmação (vermelha, destrutiva) fica no alerta
            LocalActionButton(title: "Apagar",
                              systemImage: "trash",
                              tint: .laranjinha,
                              role: .destructive,
                              hint: "Pede confirmação antes de apagar o lugar da lista",
                              isExpanded: isExpanded) {
                vm.ifIsAboutToDelete = true
            }
        }
        .padding(.leading, generalPadding)
        .animation(.snappy, value: isExpanded)
    }
}

/// Botão no estilo dos botões das listas: tom pastel do app, ícone e texto em pretinho.
private struct LocalActionButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    var role: ButtonRole? = nil
    /// O que o botão faz, lido pelo VoiceOver
    var hint: String = ""
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            if #available(iOS 26.0, *) {
                label
                    .glassEffect(.regular.tint(tint).interactive(), in: Capsule())
            } else {
                label
                    .background(tint, in: Capsule())
                    .shadow(color: .gray, radius: 1.5)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(hint)
    }

    private var label: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
            if isExpanded {
                Text(title)
                    .lineLimit(1)
                    .fixedSize()
                    .transition(.opacity)
            }
        }
        .font(.body.weight(.semibold))
        .foregroundStyle(.pretinho)
        .padding(.horizontal, isExpanded ? 18 : 0)
        .frame(minWidth: 50, minHeight: 50)
        .contentShape(Capsule())
    }
}

#Preview {
    let vm = MapViewModel(cdViewModel: CDViewModel())
    VStack(alignment: .leading, spacing: 24) {
        LocalButtons(vm: vm, generalPadding: 20, isExpanded: false)
        LocalButtons(vm: vm, generalPadding: 20, isExpanded: true)
    }
}
