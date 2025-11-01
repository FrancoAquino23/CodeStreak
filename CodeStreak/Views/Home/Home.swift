
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(HomeViewModel.self) var viewModel
    @State private var selectedHabit: Habit?
    @State private var showingCreationSheet = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    UserStatsHeaderView()
                    Text("Your Daily Coding Tasks")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    if viewModel.userHabits.isEmpty {
                        Text("No tasks found. Tap the '+' button to add your first Habit.")
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

struct HabitCreationView: View {
    var body: some View {
        Text("Habit Creation View Placeholder")
            .font(.title)
            .padding()
    }
}
