import SwiftUI

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let firstName: String?
    let lastName: String?
    let token: String

    var profileIcon: ProfileIcon = .avatar1

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "firstname"
        case lastName = "lastname"
        case token
    }

    var fullName: String {
        var components = PersonNameComponents()
        components.givenName = firstName
        components.familyName = lastName

        let formatter = PersonNameComponentsFormatter()
        return formatter.string(from: components).trimmingCharacters(in: .whitespaces)
    }
}
