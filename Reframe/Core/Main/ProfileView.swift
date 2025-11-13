import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.userSession) var session: UserSession
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteAlert = false
    
    var body: some View {
        @Bindable var session = session
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                Spacer(minLength: 20)
                
                Button {
                    session.triggerEditAvatar()
                } label: {
                    Image(systemName: session.selectedAvatar.rawValue)
                        .resizable()
                        .scaledToFit() // force aspect ratio
                        .frame(width: 120, height: 120)
                        .foregroundColor(session.selectedAvatar.foregroundColor)
                        .background(session.selectedAvatar.backgroundColor)
                        .clipShape(Circle()) // uniform shape
                        .shadow(radius: 2)
                }
                
                //Text("Hello, \(session.userName)")
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
                .alert("Delete Account?", isPresented: $showingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        Task {
                            if let token = KeychainManager.shared.getToken() {
                                AuthService.shared.deleteAccount(token: token) { result in
                                    switch result {
                                    case .success(let response):
                                        print("✅ Deleted:", response.message)
                                        Task { @MainActor in
                                            AccountDeletionService.shared.deleteAccount(
                                                session: session,
                                                modelContext: modelContext
                                            )
                                        }
                                    case .failure(let error):
                                        print("❌ Failed to delete account on server:", error)
                                    }
                                }
                            } else {
                                print("❌ No token found")
                            }
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action is permanent and will remove all data, including your insights.")
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $session.isPickerPresented) {
            IconPickerGridView(selectedIcon: $session.selectedAvatar)
                .frame(maxWidth: .infinity)
        }
    }
}

struct IconPickerGridView: View {
    @Binding var selectedIcon: ProfileIcon
    @Environment(\.dismiss) private var dismiss
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Choose your avatar")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(ProfileIcon.allCases) { icon in
                    Button {
                        selectedIcon = icon
                    } label: {
                        ZStack {
                            Circle()
                                .fill(icon.backgroundColor)
                                .frame(width: 80, height: 80)
                            Image(systemName: icon.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(icon.foregroundColor)
                            if selectedIcon == icon {
                                Circle()
                                    .stroke(Color.blue, lineWidth: 3)
                                    .frame(width: 88, height: 88)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            Button("Close") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
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

