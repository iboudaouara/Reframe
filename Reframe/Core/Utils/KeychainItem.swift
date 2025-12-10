import Foundation
import Security

struct KeychainItem {
    private static let service = "com.reframe.applelogin"
    private static let account = "appleUserIdentifier"

    static func saveUserIdentifier(_ id: String) {
        if let data = id.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data
            ]
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    static func getUserIdentifier() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    static func deleteUserIdentifier() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

struct KeychainKeys {
    static let tokenService = "com.reframe.apptoken"
    static let tokenAccount = "accessToken"
}

final class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    func saveToken(_ token: String) {
        KeychainItem.saveUserIdentifier(token)
    }

    func getToken() -> String? {
        KeychainItem.getUserIdentifier()
    }

    func deleteToken() {
        KeychainItem.deleteUserIdentifier()
    }
}
