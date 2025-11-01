
import SwiftUI

struct UserStatsHeaderView: View {
    @Environment(HomeViewModel.self) var viewModel

    private var stats: UserStats? {
        return viewModel.currentUserStats
    }
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Level \(stats?.level ?? 1)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "person.crop.circle")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading, spacing: 5) {
                let progress = Double(stats?.currentXP ?? 0) / Double(stats?.xpToNextLevel ?? 1000)
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 10)
                    .cornerRadius(5)
                Text("\(stats?.currentXP ?? 0) / \(stats?.xpToNextLevel ?? 1000) XP to Level \(stats?.level ?? 1 + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                StatBadge(value: stats?.lives ?? 0, icon: "heart.fill", color: .red)
                StatBadge(value: stats?.credits ?? 0, icon: "dollarsign.circle.fill", color: .yellow)
                Spacer()
            }
        }
        .padding(.bottom, 10)
    }
}

struct StatBadge: View {
    let value: Int
    let icon: String
    let color: Color
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text("\(value)")
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
