import SwiftUI

struct CustomTextField: View {
    var placeholder: LocalizedStringKey
    @Binding var text: String
    var isSecure: Bool = false
    var contentType: UITextContentType? = nil

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(contentType)
                    .autocapitalization(.none)
                    .keyboardType(
                        contentType == .emailAddress ? .emailAddress : .default
                    )
            }
                
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .foregroundColor(.white)
        .frame(maxWidth: 380)


    }

}

/*extension TextContentType {
 init?(_ uiKitType: UITextContentType?) {
 guard let uiKitType else { return nil }

 switch uiKitType {
 case .emailAddress: self = .emailAddress
 case .password: self = .password
 case .givenName: self = .givenName
 case .familyName: self = .familyName
 default: return nil
 }
 }
 }*/
