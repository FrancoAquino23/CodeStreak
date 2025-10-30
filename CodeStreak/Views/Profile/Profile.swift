
import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Profile...")
                } else if let user = viewModel.user {
                    List {
                        Section {
                            UserHeaderView(user: user)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        Section(header: Text("Global Stats")) {
                            StatRow(label: "Total XP", value: "\(user.totalXP)")
                            StatRow(label: "Best Streak", value: "\(user.globalBestStreak) days")
                            StatRow(label: "Total Credits", value: "₡\(user.credits)")
                        }
                        Section(header: Text("Best Habit Streaks")) {
                            if viewModel.habitsSummary.isEmpty {
                                Text("No habits created yet")
                            } else {
                                ForEach(viewModel.habitsSummary, id: \.name) { summary in
                                    HStack {
                                        Text(summary.name)
                                        Spacer()
                                        Text("\(summary.bestStreak) days")
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                        }
                        Section(header: Text("Achievements")) {
                            ForEach(viewModel.achievements, id: \.name) { achievement in
                                AchievementRow(achievement: achievement)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    Text("[ERROR] - Loading user data")
                }
            }
            .navigationTitle("Your Profile")
            .onAppear {
                viewModel.loadProfileData()
            }
        }
    }
}

struct UserHeaderView: View {
    let user: User
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            Text("Level \(user.level)")
                .font(.largeTitle)
                .fontWeight(.heavy)
            Text("\(user.totalXP) XP")
                .font(.headline)
                .foregroundColor(.secondary)
            HStack(spacing: 5) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(user.lives) Lives")
                    .fontWeight(.medium)
            }
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    var body: some View {
        HStack {
            Image(systemName: achievement.isUnlocked ? "lock.open.fill" : "lock.fill")
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            VStack(alignment: .leading) {
                Text(achievement.name)
                    .fontWeight(.semibold)
                    .strikethrough(achievement.isUnlocked)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if !achievement.isUnlocked {
                Text("\(achievement.requiredStreak) days")
                    .font(.caption)
            }
        }
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}
