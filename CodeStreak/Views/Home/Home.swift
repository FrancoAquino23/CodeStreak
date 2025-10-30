
import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Stats...")
                } else if let stats = viewModel.currentUserStats {
                    contentView(stats: stats)
                } else {
                    ContentUnavailableView("Welcome to CodeStreak!",
                                           systemImage: "bolt.badge.a",
                                           description: Text("The game needs a user to start. Try restarting the app"))
                }
            }
            .navigationTitle("CodeStreak")
        }
    }
    
    private func contentView(stats: UserStats) -> some View {
        List {
            UserStatsHeaderView(stats: stats)
            Section("Your Daily Coding Tasks") {
                if viewModel.userHabits.isEmpty {
                    Text("No tasks found. Try adding a new Habit")
                }
                ForEach(viewModel.userHabits) { habit in
                    HabitRowView(
                        habit: habit,
                        onCommit: {
                            viewModel.commitHabit(habitID: habit.id)
                        }
                    )
                }
            }
            if let result = viewModel.lastCommitResult {
                CommitResultBanner(result: result)
            }
            Section("Lives & Store") {
                Button("Buy 1 Life (50 Credits)") {
                    viewModel.purchaseLives(amount: 1)
                }
            }
        }
    }
}

struct UserStatsHeaderView: View {
    let stats: UserStats
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Level \(stats.level)")
                Spacer()
                Text("Lives: \(stats.lives)")
                Text("Credits: \(stats.credits)")
            }
            Text("Best Streak: \(stats.globalBestStreak)")
        }
        .padding(.vertical, 5)
    }
}

struct HabitRowView: View {
    let habit: Habit
    let onCommit: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(habit.name).font(.headline)
                Text("Streak: \(habit.currentStreak) | Tech: \(habit.technology)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Commit") {
                onCommit()
            }
            .buttonStyle(.borderedProminent)
        }
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
                Text("New Streak: \(result.newStreak) | Gained \(result.xpGained) XP & \(result.creditsGained)")
            }
            if result.isStreakBroken {
                Text("STREAK BROKEN! (Lives saved: \(result.livesLost))")
                    .foregroundStyle(.red)
            }
        }
    }
}
