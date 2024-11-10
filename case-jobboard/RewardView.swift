import SwiftUI

// MARK: - Models
struct RewardTier: Identifiable {
    let id: Int
    let name: String
    let emoji: String
    let color: Color
    let requiredPoints: Int
    let benefits: [String]
    
    static let tiers: [RewardTier] = [
        RewardTier(
            id: 3,
            name: "Diamond",
            emoji: "💎",
            color: .indigo,
            requiredPoints: 1000,
            benefits: [
                "Exclusive job offers",
                "VIP support 24/7",
                "Priority job application",
                "Custom job alerts",
                "Direct messaging with employers"
            ]
        ),
        RewardTier(
            id: 2,
            name: "Gold",
            emoji: "🥇",
            color: .orange,
            requiredPoints: 500,
            benefits: [
                "Early access to new jobs",
                "Priority notifications",
                "Profile boost",
                "Extended job history"
            ]
        ),
        RewardTier(
            id: 1,
            name: "Silver",
            emoji: "🥈",
            color: .gray,
            requiredPoints: 100,
            benefits: [
                "Regular job postings",
                "Personalized recommendations",
                "Basic profile features"
            ]
        )
    ]
    
    static func calculateTier(from points: Int) -> RewardTier {
        return tiers.first { points >= $0.requiredPoints } ?? defaultTier
    }
    
    static let defaultTier = RewardTier(
        id: 0,
        name: "No Tier",
        emoji: "❓",
        color: .secondary,
        requiredPoints: 0,
        benefits: ["Start applying to earn points!"]
    )
}

// MARK: - View Model
class RewardViewModel: ObservableObject {
    @Published var points: Int
    @Published var showingAchievementAlert = false
    @Published var lastEarnedPoints = 0
    private var previousTier: RewardTier
    
    var currentTier: RewardTier {
        RewardTier.calculateTier(from: points)
    }
    
    var nextTier: RewardTier? {
        RewardTier.tiers.first { $0.requiredPoints > points }
    }
    
    var progressToNextTier: Double {
        guard let next = nextTier else { return 1.0 }
        let currentMin = currentTier.requiredPoints
        let progress = Double(points - currentMin) / Double(next.requiredPoints - currentMin)
        return min(max(progress, 0), 1)
    }
    
    var pointsToNextTier: Int? {
        guard let next = nextTier else { return nil }
        return next.requiredPoints - points
    }
    
    init(initialPoints: Int = 450) {
        self.points = initialPoints
        self.previousTier = RewardTier.calculateTier(from: initialPoints)
    }
    
    func simulateEarnPoints() {
        previousTier = currentTier
        lastEarnedPoints = Int.random(in: 10...50)
        
        withAnimation(.spring()) {
            points += lastEarnedPoints
        }
        
        if currentTier.id > previousTier.id {
            showingAchievementAlert = true
        }
    }
}

// MARK: - Main View
struct RewardView: View {
    @StateObject private var viewModel = RewardViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                tierBadgeSection
                pointsAndProgressSection
                benefitsSection
                nextTierSection
                applyButton
            }
            .padding()
        }
        .background(backgroundGradient)
        .alert("New Tier Achieved! 🎉", isPresented: $viewModel.showingAchievementAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Congratulations! You've reached \(viewModel.currentTier.name) tier!")
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                colorScheme == .dark ? Color.black : Color.white,
                viewModel.currentTier.color.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var tierBadgeSection: some View {
        VStack(spacing: 10) {
            Text(viewModel.currentTier.emoji)
                .font(.system(size: 60))
            
            Text("ReVision Energy \(viewModel.currentTier.name)")
                .font(.title2.bold())
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(viewModel.currentTier.color.opacity(0.2))
                )
        }
        .card()
    }
    
    private var pointsAndProgressSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("\(viewModel.points) Points")
                    .font(.title3.bold())
                
                if viewModel.lastEarnedPoints > 0 {
                    Text("+\(viewModel.lastEarnedPoints)")
                        .foregroundColor(.green)
                        .font(.subheadline.bold())
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            ProgressView(value: viewModel.progressToNextTier) {
                if let pointsNeeded = viewModel.pointsToNextTier {
                    Text("\(pointsNeeded) points to next tier")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .tint(viewModel.currentTier.color)
        }
        .card()
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Benefits")
                .font(.headline)
            
            ForEach(viewModel.currentTier.benefits, id: \.self) { benefit in
                Label {
                    Text(benefit)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(viewModel.currentTier.color)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
    
    @ViewBuilder
    private var nextTierSection: some View {
        if let nextTier = viewModel.nextTier {
            VStack(alignment: .leading, spacing: 15) {
                Text("Next Tier Benefits")
                    .font(.headline)
                
                HStack {
                    Text(nextTier.emoji)
                        .font(.title2)
                    
                    Text(nextTier.name)
                        .font(.title3.bold())
                        .foregroundColor(nextTier.color)
                }
                
                ForEach(nextTier.benefits, id: \.self) { benefit in
                    Label {
                        Text(benefit)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundColor(nextTier.color)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        }
    }
    
    private var applyButton: some View {
        Button(action: viewModel.simulateEarnPoints) {
            Label("Apply for a Job", systemImage: "briefcase.fill")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [viewModel.currentTier.color, viewModel.currentTier.color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Supporting Views and Modifiers
struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            )
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

extension View {
    func card() -> some View {
        modifier(CardModifier())
    }
}

// MARK: - Preview
struct RewardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RewardView()
            RewardView()
                .preferredColorScheme(.dark)
        }
    }
}
