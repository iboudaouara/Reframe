import SwiftUI

struct CarouselFeatures: View {
    private let features = FeatureCatalog.all
    
    var body: some View {
        TabView {
            ForEach(features) { feature in
                VStack(spacing: 12) {
                    Image(systemName: feature.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .foregroundColor(.black)

                    Text(feature.title)
                        .font(.title2)
                        .bold()

                    Text(feature.description)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                        .shadow(color:.black, radius: 6)
                }
                .padding()
            }
        }
        .frame(height: 250)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}

struct Feature: Identifiable {
    let id = UUID()
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let imageName: String
}

struct FeatureCatalog {
    static let all: [Feature] = [
        Feature(title: "Track Thoughts", description: "Log and reflect on your daily thoughts.", imageName: "brain.head.profile"),
        Feature(title: "Get Insights", description: "Receive personalized insights to improve mindset.", imageName: "lightbulb"),
        Feature(title: "Daily Reminders", description: "Stay on track with gentle reminders.", imageName: "bell")
    ]
}
