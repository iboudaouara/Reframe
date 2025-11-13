import SwiftUI
import SwiftData

struct InsightView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var userInput: String = ""
    @State private var controller = InsightController()
    @State private var showSaveConfirmation = false

    var body: some View {
        ZStack {
            Color.blue.opacity(0.6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    Image("Logo")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 6)

                    Text("Reframe")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)

                    Text("Turn your thought into an insight")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                    TextField("Type your thought here...", text: $userInput)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.horizontal, 32)

                    Button(action: {
                        controller.generateInsight(from: userInput)
                    }) {
                        if controller.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(12)
                                .padding(.horizontal, 32)
                        } else {
                            Text("Generate Insight")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal, 32)
                        }
                    }

                    if let insight = controller.generatedInsight {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Insight:")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    saveInsight()
                                }) {
                                    Label("Save", systemImage: "square.and.arrow.down")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }

                            Text(insight)
                                .padding()
                                .background(Color.white)
                                .foregroundStyle(.black)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                        }
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .slide))
                    }

                    if let error = controller.errorMessage {
                        Text("Erreur: \(error)")
                            .foregroundColor(.red)
                            .padding(.horizontal, 32)
                    }

                    Spacer()
                }
            }
        }
    }
    private func saveInsight() {
            guard let insight = controller.generatedInsight, !userInput.isEmpty else { return }

            let newInsight = Insight(
                userThought: userInput,
                generatedInsight: insight
            )

            modelContext.insert(newInsight)

            // Sauvegarder immédiatement
            try? modelContext.save()

            // Afficher la confirmation
            withAnimation {
                showSaveConfirmation = true
            }

            // Réinitialiser après 2 secondes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSaveConfirmation = false
                    userInput = ""
                    controller.generatedInsight = nil
                }
            }

            print("✅ Insight saved to database")
        }
}


#Preview {
    InsightView()
}
