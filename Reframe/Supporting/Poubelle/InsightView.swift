import SwiftUI
import SwiftData

struct InsightView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var userInput: String = ""
    // NOUVELLES VARIABLES D'ÉTAT LOCALES
        @State private var isLoading: Bool = false
        @State private var generatedInsight: String?
        @State private var errorMessage: String?
    //@State private var controller = InsightController()
    @State private var showSaveConfirmation = false
    private let insightService = InsightService.shared
    @Environment(Session.self) var session

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

                    Button(action: handleGenerateInsight) {
                        if isLoading {
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

                    if let insight = generatedInsight {
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

                    if let error = errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding(.horizontal, 32)
                    }

                    Spacer()
                }
            }
        }
    }

    private func handleGenerateInsight() {
            generatedInsight = nil
            errorMessage = nil

            Task { @MainActor in
                isLoading = true

                defer {
                    isLoading = false
                }

                do {
                    let response = try await insightService.generateInsight(from: userInput)

                    if let reply = response.reply {
                        self.generatedInsight = reply
                    } else if let error = response.error {
                        self.errorMessage = error
                    } else {
                        self.errorMessage = String(localized: "Server returned an invalid response.")
                    }
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }

        private func saveInsight() {
            guard let insightText = generatedInsight,
                  !userInput.isEmpty,
                  let token = session.user?.token
                  else {
                errorMessage = String(localized: "You must be logged in to save insights.")
                return
            }

            let newInsight = Insight(
                userThought: userInput,
                generatedInsight: insightText,
                syncStatus: .pending
            )
            modelContext.insert(newInsight)
            try? modelContext.save()

            Task {
                do {
                    try await InsightService.shared.uploadInsight(insight: newInsight, token: token)

                    withAnimation {
                        showSaveConfirmation = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSaveConfirmation = false
                            userInput = ""
                            generatedInsight = nil
                        }
                    }
                    print("✅ Insight saved and synced.")

                } catch {
                    newInsight.syncStatus = .error
                    try? modelContext.save()

                    print("❌ Erreur de synchronisation serveur:", error)
                    errorMessage = String(localized: "Insight saved locally, but failed to sync: \(error.localizedDescription)")
                }
            }
        }
    }



#Preview {
    InsightView()
}
