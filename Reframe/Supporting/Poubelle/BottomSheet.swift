import SwiftUI

struct BottomSheet<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack() {
            content
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
    }
}

#Preview {
    BottomSheet(content: {Text("Thomas")})
}
