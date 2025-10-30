
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(HomeViewModel.self) var viewModel
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Stats...")
                } else if let stats = viewModel.currentUserStats {
                    ScrollView {
                        VStack(spacing: 20) {
                            contentView(stats: stats)
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.loadInitialData()
                    }
                } else {
                    ContentUnavailableView("Welcome to CodeStreak!",
                                           systemImage: "bolt.badge.a",
                                           description: Text("The game needs a user to start. Try restarting the app"))
                }
            }
            .navigationTitle("CodeStreak")
        }
    }

    @ViewBuilder
    private func contentView(stats: UserStats) -> some View {
        UserStatsHeaderView(stats: stats)
            .padding(.horizontal)
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Daily Coding Tasks")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            if viewModel.userHabits.isEmpty {
                Text("No tasks found. Tap the '+' button to add your first Habit")
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
            }
            ForEach(viewModel.userHabits) { habit in
                HabitCardView(
                    habit: habit,
                    commitAction: { habitID in
                        viewModel.commitHabit(habitID: habitID)
                    }
                )
                .padding(.horizontal)
            }
        }
        if let result = viewModel.lastCommitResult {
            CommitResultBanner(result: result)
                .padding(.horizontal)
        }
        Spacer()
    }
}

struct UserStatsHeaderView: View {
    let stats: UserStats
    private var xpNeeded: Int { return stats.level * 1000 }
    var body: some View {
        VStack(spacing: 15) {
            XPBarView(
                currentXP: stats.totalXP,
                xpForNextLevel: xpNeeded,
                currentLevel: stats.level
            )
            HStack {
                LifeStatusBarView(livesRemaining: stats.lives)
                Spacer()
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(stats.credits)")
                        .font(.title2)
                        .fontWeight(.heavy)
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 1))
            }
        }
        .padding(.vertical, 10)
    }
}

struct CommitResultBanner: View {
    let result: CommitResult
    var body: some View {
        VStack(alignment: .leading) {
            Text(result.success ? "COMMIT SUCCESSFUL!" : "COMMIT SKIPPED/FAILED")
                .font(.headline)
                .foregroundStyle(result.success ? .green : .orange)
            if result.success {
                Text("New Streak: \(result.newStreak) | Gained \(result.xpGained) XP & \(result.creditsGained) Credits")
            }
            if result.isStreakBroken {
                Text("STREAK BROKEN! (Lives used: \(result.livesLost))")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(result.success ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}
