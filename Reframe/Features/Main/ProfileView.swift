import SwiftUI
import SwiftData

struct ProfileView: View {

    @Environment(Session.self) private var session
    @Environment(\.modelContext) private var modelContext

    @State private var showingDeleteAlert = false
    @State private var isPickerPresented = false

    var body: some View {

        ScrollView {

            VStack(alignment: .center, spacing: 24) {

                Spacer(minLength: 20)

                if session.isGuest {

                    guestView

                } else {

                    authenticatedView

                }

                Spacer()

            }
            .padding()

        }
        .sheet(isPresented: $isPickerPresented) {
            IconPickerGridView(
                currentIcon: session.user?.profileIcon ?? .avatar1
            ) { newIcon in
                // Action : On met à jour la session et on ferme
                Task {
                    try? await session.updateAvatar(newIcon)
                    isPickerPresented = false
                }
            }
            .presentationDetents([.medium])
        }
        .alert("Delete Account?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await session.deleteAccount(modelContext: modelContext)
                        // The user is now logged out and their data is cleared.
                    } catch {
                        // Optionally, show an alert to the user that deletion failed.
                        print("❌ Failed to delete account:", error)
                    }
                }
            }


            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action is permanent and will remove all data, including your insights.")
        }
    }

    private var guestView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.gray.opacity(0.5))

            Text("Guest Mode")
                .font(.title2.bold())

            Text("Create an account to save your history and access all features.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                session.logout()
            } label: {
                Text("Sign Up / Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
        }
    }

    private var authenticatedView: some View {
        VStack(spacing: 24) {
            // Avatar Button
            Button {
                isPickerPresented = true
            } label: {
                // On affiche la VRAIE donnée du user
                if let icon = session.user?.profileIcon {
                    Image(systemName: icon.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(icon.foregroundColor)
                        .background(icon.backgroundColor)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
            }

            Text("Hello, \(session.user?.firstName ?? "User")")
                .font(.title2.bold())

            // Logout
            Button(action: { session.logout() }) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }

            // Delete
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Text("Delete Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(12)
            }
        }
    }
    /*
     Button { session.triggerEditAvatar() } label: {
     Image(systemName: session.selectedAvatar.rawValue)
     .resizable().scaledToFit()
     .frame(width: 120, height: 120)
     .foregroundColor(session.selectedAvatar.foregroundColor)
     .background(session.selectedAvatar.backgroundColor)
     .clipShape(Circle())
     .shadow(radius: 2)
     }
     //let nickname: String? = nil
     //let fullName: String = "John Appleseed"
     //let informalGreeting = "Hi \(nickname ?? fullName)"

     Text("Hello, \(session.user?.fullName ?? "User")")
     //  .font(.largeTitle.bold())

     Button(action: { session.logout() }) {
     Text("Logout")
     .frame(maxWidth: .infinity)
     .padding()
     .background(Color.gray.opacity(0.2))
     .foregroundColor(.primary)
     .cornerRadius(12)
     }

     Button(role: .destructive) {
     showingDeleteAlert = true
     } label: {
     Text("Delete Account")
     .frame(maxWidth: .infinity)
     .padding()
     .background(Color.red.opacity(0.2))
     .foregroundColor(.red)
     .cornerRadius(12)
     }
     */
}

struct IconPickerGridView: View {
    // Données en entrée (Lecture seule)
    let currentIcon: ProfileIcon
    // Action en sortie (Callback)
    let onSelection: (ProfileIcon) -> Void

    @Environment(\.dismiss) private var dismiss
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose your avatar")
                .font(.headline)
                .padding(.top)

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(ProfileIcon.allCases) { icon in
                    Button {
                        onSelection(icon) // On renvoie le choix au parent
                    } label: {
                        ZStack {
                            // Cercle de fond
                            Circle()
                                .fill(icon.backgroundColor)
                                .frame(width: 80, height: 80)

                            // Icône
                            Image(systemName: icon.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(icon.foregroundColor)

                            // Bordure de sélection
                            if currentIcon == icon {
                                Circle()
                                    .stroke(Color.blue, lineWidth: 3)
                                    .frame(width: 88, height: 88)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)

            Spacer()

            Button("Close") {
                dismiss()
            }
            .padding()
        }
        .padding(.vertical)
    }
}



enum ProfileIcon: String, CaseIterable, Identifiable {
    case avatar1 = "person.circle.fill"
    case avatar2 = "person.crop.circle.fill"
    case avatar3 = "person.crop.square.fill"
    case avatar4 = "person.fill"
    case avatar5 = "person.2.fill"
    case avatar6 = "person.3.fill"
    case avatar7 = "person.crop.circle.badge.checkmark"
    case avatar8 = "person.crop.circle.badge.xmark"
    case avatar9 = "person.crop.square.fill.and.at.rectangle"

    var id: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .avatar1, .avatar4: return Color.blue.opacity(0.2)
        case .avatar2, .avatar5: return Color.green.opacity(0.2)
        case .avatar3, .avatar6: return Color.orange.opacity(0.2)
        case .avatar7: return Color.purple.opacity(0.2)
        case .avatar8: return Color.red.opacity(0.2)
        case .avatar9: return Color.yellow.opacity(0.2)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .avatar1, .avatar4: return Color.blue
        case .avatar2, .avatar5: return Color.green
        case .avatar3, .avatar6: return Color.orange
        case .avatar7: return Color.purple
        case .avatar8: return Color.red
        case .avatar9: return Color.yellow
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .avatar3, .avatar6, .avatar9: return 16
        default: return 40
        }
    }
}
