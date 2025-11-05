
import SwiftUI
import SwiftData
import Combine

struct HomeView: View {
    @Environment(HomeViewModel.self) var viewModel
    @State private var selectedHabit: Habit?
    @State private var showingCreationSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    UserStatsHeaderView()
                    if let user = viewModel.currentUser, !user.activeBoosters.filter({ $0.isActive }).isEmpty {
                        ActiveBoostersView(boosters: user.activeBoosters.filter({ $0.isActive }))
                            .padding(.top, 10)
                    }
                    Text("Your daily code tasks")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    if viewModel.userHabits.isEmpty {
                        Text("No tasks found. Tap the '+' button to add your first habit")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 50)
                    } else {
                        ForEach(viewModel.userHabits, id: \.id) { habit in
                            HabitCardView(habit: habit) { habitToChallenge in
                                self.selectedHabit = habitToChallenge
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("CodeStreak")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreationSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreationSheet) {
                HabitCreationView()
            }
            .sheet(item: $selectedHabit) { habit in
                CodeChallengeView(habit: habit)
                    .environment(viewModel)
            }
            .overlay(alignment: .bottom) {
                if let result = viewModel.lastCommitResult {
                    CommitStatusBanner(result: result)
                        .onAppear {
                            Task {
                                try? await Task.sleep(for: .seconds(3))
                                viewModel.lastCommitResult = nil
                            }
                        }
                }
            }
            .onChange(of: selectedHabit) { _, newValue in
                if newValue == nil {
                    viewModel.currentChallenge = nil
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadInitialData()
                }
            }
        }
    }
}

struct ActiveBoostersView: View {
    let boosters: [ActiveBooster]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Boosters Activos")
                .font(.headline)
                .foregroundColor(.orange)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(boosters.filter { $0.isActive }) { booster in
                        BoosterStatusCard(booster: booster)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct BoosterStatusCard: View {
    @Bindable var booster: ActiveBooster
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: booster.type == .doubleXP ? "flame.fill" : "creditcard.fill")
                .foregroundColor(booster.type == .doubleXP ? .red : .yellow)
                .font(.title3)
            Text(booster.type == .doubleXP ? "Double XP" : "Double Credits")
                .font(.subheadline)
                .fontWeight(.bold)
            Text(timeString(from: timeRemaining))
                .font(.caption2)
                .monospacedDigit()
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(width: 120)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }

    private func updateTimeRemaining() {
        let remaining = booster.expirationDate.timeIntervalSinceNow
        if remaining > 0 {
            self.timeRemaining = remaining
        } else {
            self.timeRemaining = 0
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        guard timeInterval > 0 else {
            return "Expirado"
        }
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d min", minutes, seconds)
    }
}

struct HabitCreationView: View {
    var body: some View {
        Text("Habit Creation View Placeholder")
            .font(.title)
            .padding()
    }
}
