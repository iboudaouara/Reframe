struct MockAuthService: AuthServiceProtocol {

        func loginWithApple(data: AppleAuthData, definitiveEmail: String) async throws -> User {
            return User(
                id: 888,
                email: definitiveEmail,
                firstName: data.firstName ?? "Apple",
                lastName: data.lastName ?? "User",
                token: "fake-apple-token-456"
            )
        }

        func loadUserFromSession() async throws -> User {
            return User(
                id: 999,
                email: "cached@test.com",
                firstName: "Cached",
                lastName: "User",
                token: "fake-jwt-token-123"
            )
        }


        func login(email: String, password: String) async throws -> User {
            // Simulation : Si le mot de passe est "error", on simule un échec
            if password == "error" {
                throw URLError(.userAuthenticationRequired)
            }

            // Sinon, on retourne un utilisateur fictif immédiatement
            return User(
                id: 999,
                email: email,
                firstName: "Test",
                lastName: "User",
                token: "fake-jwt-token-123"
            )
        }

        // --- Méthodes obligatoires du protocole (implémentation vide ou par défaut) ---
        func logout() { }

        func signup(firstName: String, lastName: String, email: String, password: String) async throws -> User {
            return User(id: 999, email: email, firstName: firstName, lastName: lastName, token: "signup-token")
        }

        func deleteAccount(token: String) async throws -> DeleteAccountResponse {
            return DeleteAccountResponse(message: "Account deleted")
        }

        func loginWithApple(userIdentifier: String, email: String?, firstName: String?, lastName: String?) async throws -> User {
            return User(id: 888, email: email ?? "apple@test.com", firstName: firstName, lastName: lastName, token: "apple-token")
        }

        func verifyTokenAndFetchUser(token: String) async throws -> User {
            return User(id: 999, email: "verified@test.com", firstName: "Verified", lastName: "User", token: token)
        }
    }