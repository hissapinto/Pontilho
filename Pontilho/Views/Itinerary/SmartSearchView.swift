//
//  SmartSearchView.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 02/11/26.
//

import SwiftUI
import MapKit

/// Sheet da "Pesquisa inteligente" (Roteiro do dia): um campo só e um botão que muda
/// conforme o pedido (buscar, montar roteiro ou tentar a sorte).
struct SmartSearchView: View {
    @Environment(CDViewModel.self) private var cdViewModel
    @Bindable var vm: ItineraryViewModel
    /// Localização da pessoa (do MapViewModel)
    var location: CLLocationCoordinate2D?
    /// Toque num card: a sheet desce e o lugar vira pin no mapa
    var onSelectStop: (ItineraryStop) -> Void = { _ in }
    /// "Ver no mapa": a sheet desce e todas as sugestões viram pins
    var onShowAll: () -> Void = {}

    let generalPadding: CGFloat = 20

    @FocusState private var isFieldFocused: Bool
    /// Card tocado (a sheet está descendo para mostrar o lugar)
    @State private var selectedStopID: String?

    /// Cor do botão: passa pelas cores das listas, uma a cada 2 segundos
    @State private var buttonColorIndex = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Altura do formulário (título até o botão), medida na tela e guardada no aparelho.
    /// Guardando, a sheet já abre na altura certa (sem abrir numa e corrigir para outra).
    @AppStorage("smartSearchFormHeightV2") private var formHeight: Double = 400
    @State private var detent: PresentationDetent

    init(vm: ItineraryViewModel, location: CLLocationCoordinate2D? = nil,
         onSelectStop: @escaping (ItineraryStop) -> Void = { _ in },
         onShowAll: @escaping () -> Void = {}) {
        _vm = Bindable(vm)
        self.location = location
        self.onSelectStop = onSelectStop
        self.onShowAll = onShowAll
        let stored = UserDefaults.standard.double(forKey: "smartSearchFormHeightV2")
        ///Voltando de um pin com o resultado guardado: já abre expandida
        _detent = State(initialValue: vm.hasResult ? .expandida : .height(Self.sheetHeight(forForm: stored > 0 ? stored : 400)))
    }

    /// Formulário + espaço do topo (30) + respiro abaixo do botão (20)
    private static func sheetHeight(forForm height: Double) -> CGFloat {
        CGFloat(height) + 30 + 20
    }

    /// Abre do tamanho do formulário; dá para arrastar até a expandida, como nas outras sheets
    private var fittedDetent: PresentationDetent { .height(Self.sheetHeight(forForm: formHeight)) }
    private var hasResult: Bool { vm.hasResult }
    private var detents: Set<PresentationDetent> { [fittedDetent, .expandida] }

    var body: some View {
        NavigationStack {
            ///Sempre a mesma ScrollView (antes era ViewThatFits: com o teclado, ela trocava de versão,
            ///recriava o campo e perdia o foco — era o "pulo"). Só rola se o conteúdo não couber.
            ScrollView {
                sheetBody
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            ///Toque na área vazia abaixo do conteúdo também fecha o teclado
            .background {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { isFieldFocused = false }
            }
            ///"Limpar pesquisa" fixo no pé da sheet, mesmo com a lista rolando
            .safeAreaInset(edge: .bottom) {
                ///Só com a sheet no tamanho maior
                if hasResult && detent == .expandida {
                    VStack(spacing: 4) {
                        showAllButton
                        clearButton
                    }
                    .padding(.top, 8)
                }
            }
        }
        .presentationDetents(detents, selection: $detent)
        ///Formulário mudou de altura (aviso, erro…): acompanha, se a sheet não estiver expandida
        .onChange(of: formHeight) {
            if detent != .expandida { detent = fittedDetent }
        }
        ///Chegou resultado: a sheet cresce sozinha. Limpou a pesquisa: volta ao tamanho do formulário
        .onChange(of: hasResult) {
            withAnimation(.snappy) {
                detent = hasResult ? .expandida : fittedDetent
            }
        }
    }

    /// Conteúdo da sheet
    private var sheetBody: some View {
        VStack(alignment: .leading) {
            ///Depois da pesquisa, o que fica abaixo do traço vira o resultado
            if hasResult {
                header
                results
            } else {
                form
                    ///Sempre na altura natural, não importa o tamanho da sheet
                    .fixedSize(horizontal: false, vertical: true)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        ///Só mede com a sheet no tamanho do formulário, arredonda e ignora variações mínimas
                        guard detent != .expandida, !vm.isGenerating, height > 0, height < 700 else { return }
                        let rounded = height.rounded()
                        if abs(rounded - formHeight) >= 1 { formHeight = rounded }
                    }
            }

            Spacer()
        }
        .padding(.top, 30)
        ///Toque fora do campo fecha o teclado (no fundo, para não disputar o toque com o campo)
        .background {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { isFieldFocused = false }
        }
    }

    /// Título, subtítulo e traço (iguais antes e depois da pesquisa)
    private var header: some View {
        VStack(alignment: .leading) {
            Text("Pesquisa inteligente")
                .font(.system(.title, design: .serif, weight: .heavy))
                .padding(.leading, generalPadding)

            Text("Powered by Apple Intelligence")
                .font(.footnote)
                .bold()
                .padding(.leading, generalPadding)

            Divider()
                .padding([.leading, .trailing], generalPadding)
        }
    }

    /// Cabeçalho, explicação, campo e botão (define a altura inicial da sheet)
    private var form: some View {
        VStack(alignment: .leading) {
            header

            Text("Procure uma categoria, peça um roteiro ou tente a sua sorte. Para buscar num bairro, use “em”: café em Pinheiros.")
                .font(.footnote)
                .padding([.leading, .trailing], generalPadding)
                .fixedSize(horizontal: false, vertical: true)

            ///Apple Intelligence desligada ou se preparando: explica o motivo
            if case .unavailable(let reason) = vm.availability {
                Text(reason)
                    .font(.footnote)
                    .bold()
                    .padding([.leading, .trailing], generalPadding)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ///Mesmo respiro acima e abaixo do campo.
            ///Enquanto a IA pensa, o campo dá lugar ao pedido da pessoa, maior e em semibold
            Group {
                if vm.isGenerating {
                    WavingText(text: vm.submittedRequest.isEmpty ? "Sorteando" : vm.submittedRequest)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    requestField
                }
            }
            .padding([.leading, .trailing], generalPadding)
            .padding([.top, .bottom], 15)

            actionArea
                .frame(maxWidth: .infinity)

            if let error = vm.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding([.leading, .trailing], generalPadding)
                    .padding(.top, 8)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Campo

    /// Campo no estilo das fotos: contorno pretinho, cantos arredondados e fundo transparente.
    /// A altura é a dos exemplos: eles ficam invisíveis (mas ocupando espaço) quando a pessoa digita.
    private var requestField: some View {
        ZStack(alignment: .topLeading) {
            Text("Exemplos:\n• um café e depois um parque\n• comida japonesa em Pinheiros\n• museu, almoço e um bar\n• ou deixe vazio e tente a sorte")
                .font(.callout)
                .foregroundStyle(.secondary)
                .opacity(vm.request.isEmpty ? 1 : 0)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            TextField("", text: $vm.request, axis: .vertical)
                .font(.callout)
                .lineLimit(1...6)
                .focused($isFieldFocused)
                .accessibilityLabel("O que você quer fazer?")
                .accessibilityHint("Ex.: um café e depois um parque. Vazio, sorteia um lugar.")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .overlay {
            RoundedRectangle(cornerRadius: 13)
                .stroke(.pretinho, lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 13))
        .onTapGesture { isFieldFocused = true }
    }

    // MARK: - Botão (ou progresso)

    @ViewBuilder
    private var actionArea: some View {
        if let progress = vm.progress {
            ///Mesmas margens do campo: o texto não passa do alinhamento dele
            HStack(spacing: 8) {
                ProgressView()
                Text(progress)
                    .font(.footnote)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(minHeight: 50)
            .padding([.leading, .trailing], generalPadding)
        } else {
            Button {
                isFieldFocused = false
                vm.startGenerating(places: cdViewModel.locais, location: location)
            } label: {
                ///Cápsula de vidro tingida com as cores das listas (trocando aos poucos), texto pretinho
                Label(buttonTitle, systemImage: buttonIcon)
                    .font(.body.weight(.semibold))
                    .contentTransition(.opacity)
                    .foregroundStyle(.pretinho)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .modifier(TintedGlass(tint: LocalEnum.allCases[buttonColorIndex].color, shape: Capsule()))
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(vm.availability != .available)
            .animation(.snappy, value: vm.expectedMode)
            ///Troca de cor a cada 2 s, com transição suave (parado se "Reduzir movimento" estiver ligado)
            .task {
                guard !reduceMotion else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation(.easeInOut(duration: 1)) {
                        buttonColorIndex = (buttonColorIndex + 1) % LocalEnum.allCases.count
                    }
                }
            }
        }
    }

    private var buttonTitle: String {
        switch vm.expectedMode {
        case .lucky: return "Tentar a sorte"
        case .itinerary: return "Montar roteiro"
        case .toDecide: return "Buscar"
        }
    }

    private var buttonIcon: String {
        switch vm.expectedMode {
        case .lucky: return "dice"
        case .itinerary: return "map"
        case .toDecide: return "magnifyingglass"
        }
    }

    // MARK: - Resultado (provisório: na etapa 6 ele vai para o mapa)

    @ViewBuilder
    private var results: some View {
        ///Um bloco por coisa pedida; entre os blocos, um traço como o do cabeçalho
        ForEach(Array(vm.groups.enumerated()), id: \.element.id) { index, group in
            if index > 0 {
                Divider()
                    .padding([.leading, .trailing], generalPadding)
                    .padding(.top, 12)
            }

            ///Mesmo tamanho do texto explicativo do formulário
            Text(group.title)
                .font(.footnote)
                .padding([.leading, .trailing], generalPadding)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                ForEach(group.stops) { stop in
                    Button {
                        ///Um toque só: evita abrir duas vezes enquanto a sheet desce
                        guard selectedStopID == nil else { return }
                        selectedStopID = stop.id
                        onSelectStop(stop)
                    } label: {
                        card(stop)
                    }
                    .buttonStyle(CardPressStyle())
                    .accessibilityHint("Mostra o lugar no mapa")
                }
            }
            .padding([.leading, .trailing], generalPadding)
            .padding(.top, 6)
        }

        #if DEBUG
        ///O que o modelo pediu às tools e o que elas devolveram (só em desenvolvimento)
        if !vm.log.isEmpty {
            DisclosureGroup("Registro das ferramentas") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(vm.log.enumerated()), id: \.offset) { _, entry in
                        Text(entry)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .font(.footnote)
            .padding([.leading, .trailing], generalPadding)
            .padding(.top, generalPadding)
        }
        #endif
    }

    /// Mostra todas as sugestões no mapa (mesmo vidro do botão de pesquisa, sem trocar de cor)
    private var showAllButton: some View {
        Button {
            onShowAll()
        } label: {
            ///Vidro pretinho com texto branquinho
            Label("Ver no mapa", systemImage: "map")
                .font(.body.weight(.semibold))
                .foregroundStyle(.branquinho)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .modifier(TintedGlass(tint: .pretinho, shape: Capsule()))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    /// Limpa a pesquisa e volta para o campo (fechar a sheet também limpa)
    private var clearButton: some View {
        Button("Limpar pesquisa") {
            vm.reset()
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    /// Card de cada resultado: fundo na cor da lista que combina com o lugar,
    /// contorno pretinho e cantos arredondados (como as fotos); altura do próprio texto
    /// Desenho da lista (o mesmo dos botões das listas); sem lista, um ponto de interrogação do mesmo tamanho
    @ViewBuilder
    private func cardIcon(for listType: LocalEnum?) -> some View {
        if let listType {
            Image(listType.image)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "questionmark.circle")
                .resizable()
                .scaledToFit()
                .fontWeight(.medium)
                .padding(4)
                .frame(width: 40, height: 40)
                .accessibilityHidden(true)
        }
    }

    private func card(_ stop: ItineraryStop) -> some View {
        HStack(spacing: 12) {
            cardIcon(for: stop.listType)

            VStack(alignment: .leading, spacing: 4) {
                Text(stop.name)
                    .font(.subheadline.bold())
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(stop.category) · Permanência sugerida: \(stop.stayTime)")
                    .font(.footnote)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(.pretinho)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        ///Vidro tingido com a cor da lista (sem lista: vidro sem cor)
        .modifier(TintedGlass(tint: stop.listType?.color, shape: RoundedRectangle(cornerRadius: 13), interactive: false))
        ///O card inteiro recebe o toque, não só o texto
        .contentShape(RoundedRectangle(cornerRadius: 13))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SmartSearchView(vm: ItineraryViewModel())
        .environment(CDViewModel())
}

/// Mesmo estilo dos botões das listas sobre o mapa: Liquid Glass tingido no iOS 26,
/// cor sólida com sombra leve no iOS 18. Serve para o botão (cápsula) e os cards (retângulo arredondado).
private struct TintedGlass<S: Shape>: ViewModifier {
    let tint: Color?
    let shape: S
    /// Vidro que reage ao toque. Desligado nos cards: lá quem cuida do toque é o Button
    /// (o vidro interativo disputava o toque com ele e às vezes o clique falhava)
    var interactive: Bool = true

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(interactive ? .regular.tint(tint).interactive() : .regular.tint(tint), in: shape)
        } else {
            content
                .background(tint ?? .branquinho, in: shape)
                .shadow(color: .gray, radius: 1.5)
        }
    }
}

/// Texto do pedido enquanto a IA pensa: as letras pulam uma de cada vez, numa ola
/// (como o efeito de mensagens), e a cor passa pelas cores das listas, como o botão.
/// Usa TextRenderer, então o texto continua quebrando linha normalmente. Parado com "Reduzir movimento".
private struct WavingText: View {
    let text: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Cores das listas, escurecidas para o texto continuar legível sobre o vidro claro
    private static let colors: [Color] = LocalEnum.allCases.map { $0.color.darkened() }

    var body: some View {
        if reduceMotion {
            Text(text)
        } else {
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                ///Troca de cor a cada 2 s, com transição suave (igual ao botão)
                let colorIndex = Int(time / 2) % Self.colors.count
                Text(text)
                    .foregroundStyle(Self.colors[colorIndex])
                    .animation(.easeInOut(duration: 1), value: colorIndex)
                    .textRenderer(HopRenderer(time: time))
                    .padding(.top, HopRenderer.height)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(text)
        }
    }
}

/// Faz cada letra dar um pulinho, uma depois da outra; quando a ola chega ao fim, pausa e recomeça
private struct HopRenderer: TextRenderer {
    var time: Double

    /// Altura do pulo (pt)
    static let height: CGFloat = 6
    /// Atraso entre uma letra e a próxima, duração de cada pulo e pausa entre as olas (segundos)
    private let delay = 0.05
    private let hopDuration = 0.3
    private let pause = 0.5

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        ///Quantas letras há, para a ola durar o tempo certo em textos curtos e longos
        var total = 0
        for line in layout {
            for run in line { total += run.count }
        }
        let period = Double(total) * delay + hopDuration + pause

        var index = 0
        for line in layout {
            for run in line {
                for glyph in run {
                    ///Em que ponto do pulo esta letra está agora
                    var local = (time - Double(index) * delay).truncatingRemainder(dividingBy: period)
                    if local < 0 { local += period }
                    let offset = local < hopDuration ? -Self.height * sin(.pi * local / hopDuration) : 0

                    var copy = context
                    copy.translateBy(x: 0, y: offset)
                    copy.draw(glyph)
                    index += 1
                }
            }
        }
    }
}

private extension Color {
    /// Versão mais escura e saturada da cor (as cores das listas são pastel demais para texto)
    func darkened() -> Color {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Color(hue: hue, saturation: min(1, saturation * 1.6 + 0.25), brightness: brightness * 0.55)
    }
}

/// Card afunda um pouco enquanto o dedo está nele (no lugar do efeito do vidro interativo)
private struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}
