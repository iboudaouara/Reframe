import SwiftUI

struct DiagonalBackground: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let blueHeight = h * 0.5

            ZStack {
                VStack(spacing: 0) {
                    Color.blue
                        .frame(height: blueHeight)
                    Color.white
                }
                .ignoresSafeArea()

                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: blueHeight * 1.4)
                    .rotationEffect(.degrees(-12))
                    .offset(y: -blueHeight * 0.3)

                ZStack {
                    ForEach(0..<8) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(Double.random(in: 0.05...0.12)))
                            .frame(
                                width: w * CGFloat.random(in: 0.30...0.70),
                                height: blueHeight * CGFloat.random(in: 0.08...0.18)
                            )
                            .rotationEffect(.degrees(Double.random(in: -18...18)))
                            .offset(
                                x: w * CGFloat.random(in: -0.25...0.25),
                                y: -blueHeight * CGFloat.random(in: 0.10...0.85)
                            )
                            .blur(radius: 3)
                    }
                }
                .clipped()
                .frame(height: blueHeight)
                .offset(y: -h/2 + blueHeight/2)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    DiagonalBackground()
}
