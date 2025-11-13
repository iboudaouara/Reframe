import SwiftUI

struct ScreenContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { geo in
            ZStack {
                HomeBackground()

                ScrollView(showsIndicators: false) {
                    VStack {
                        content()
                    }.frame(maxWidth: .infinity, minHeight: geo.size.height, alignment: .top)
                }.frame(width: geo.size.width)
            }.frame(width: geo.size.width)
        }.ignoresSafeArea(edges: .bottom)
    }
}
