import SwiftUI
import SwiftData

struct StrategicDashboardView: View {
    @Environment(Session.self) private var session
    @Environment(\.modelContext) private var modelContext
    @State private var isSaved: Bool = false

    @State private var situationInput: String = ""
    @State private var analysis: StrategicAnalysis?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let tacticalService = TacticalService.shared

    private var isShowingError: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { _ in errorMessage = nil }
        )
    }
    var body: some View {
        ZStack {
            Color(hex: "1A1A1A").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerView

                    if let analysis = analysis {
                        ManeuverCard(maneuver: analysis.maneuver)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        Text("CONTRE-MESURES RECOMMANDÉES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        ForEach(analysis.recommendedMoves) {
                            move in CounterMoveRow(move: move)
                        }

                        if !isSaved {
                            Button(action: {
                                saveAnalysis(analysis: analysis, situation: situationInput)
                            }) {
                                Label("Sauvegarder dans l'historique", systemImage: "square.and.arrow.down")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        } else {
                            Text("✅ Analyse sauvegardée")
                                .foregroundStyle(.green)
                                .padding(.top, 8)
                        }

                        Button("Nouvelle Analyse") {
                            withAnimation {
                                self.analysis = nil;
                                self.situationInput = ""
                            }
                        }
                        .foregroundColor(.red)
                        .padding(.top)
                    } else {
                        inputSection
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .alert("Erreur Serveur", isPresented: isShowingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Une erreur inconnue est survenue.")
        }
    }

    func saveAnalysis(analysis: StrategicAnalysis, situation: String) {
        let session = TacticalSession(situation: situation, analysis: analysis)
        modelContext.insert(session)

        withAnimation {
            isSaved = true
        }

        // Petit feedback haptique
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    var headerView: some View {
        HStack {
            Image(systemName: "shield.righthalf.filled")
                .font(.system(size:28))
                .foregroundStyle(.white)
            VStack(alignment: .leading) {
                Text("RADAR SOCIAL")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Analyse de rapports de force")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(.bottom, 10)
    }

    var inputSection: some View {
        VStack(spacing: 20) {
            Text("Quelle interaction vous a destabilisé ?")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            TextEditor(text: $situationInput)
                .frame(height: 150)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundStyle(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            Button(action: runAnalysis) {
                HStack {
                    if isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Text("DÉCODER LA SITUATION")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(situationInput.isEmpty ? Color.gray : Color.white)
                .foregroundStyle(.black)
                .cornerRadius(12)
            }
            .disabled(situationInput.isEmpty || isLoading)
        }
        .padding(.top, 40)
    }

    func runAnalysis() {
        guard !situationInput.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await tacticalService.analyze(situation: situationInput)
                withAnimation {
                    self.analysis = result
                }
            } catch {
                self.errorMessage = "Erreur d'analyse: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}

struct ManeuverCard:View {
    let maneuver: Maneuver

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MANOEUVRE DÉTECTÉE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding(6)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(4)
                Spacer()
                HStack(spacing: 4) {
                    Text("DOMINATION ADVERSE:")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Text("\(maneuver.powerScore)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                }
            }
            Text(maneuver.name)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
            Text(maneuver.description)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))

            Divider().background(Color.white.opacity(0.2))

            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.yellow)
                Text(maneuver.emotionalImpact)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.yellow)
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.5), lineWidth: 1)
        )
    }
}

struct CounterMoveRow: View {
    let move: CounterMove

    var body: some View {
        Button(action: {

        }) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(move.successRate > 0.8 ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
                VStack(alignment: .leading, spacing: 6) {
                    Text(move.text)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    HStack {
                        Label("\(move.usageCount) utilisations", systemImage: "person.2")
                        Spacer()
                        Text("\(Int(move.successRate * 100))% succès")
                    }
                    .font(.caption2)
                    .foregroundStyle(.gray)
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int:UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    StrategicDashboardView()
}
