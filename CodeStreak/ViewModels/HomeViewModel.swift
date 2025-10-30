
import Foundation
import SwiftUI
import Combine
import SwiftData

@Observable
final class HomeViewModel {
    private let streakService: StreakCalculator
    private let dataManager: DataManaging
    var currentUserStats: UserStats?
    var userHabits: [Habit] = []
    var isLoading: Bool = false
    var lastCommitResult: CommitResult?
    
    init(streakService: StreakCalculator, dataManager: DataManaging) {
        self.streakService = streakService
        self.dataManager = dataManager
        Task { @MainActor in
            await loadInitialData()
        }
    }
    
    func commitHabit(habitID: UUID) {
        let result = streakService.commitDailyQuest(habitID: habitID)
        self.lastCommitResult = result
        if result.success {
            Task { @MainActor in
                await loadInitialData()
            }
        }
    }
    
    func purchaseLives(amount: Int) {
        guard amount > 0 else { return }
        let success = streakService.purchaseLives(amount: amount)
        if success {
            Task { @MainActor in
                await loadInitialData()
            }
        }
    }

    @MainActor
    func loadInitialData() async {
        guard !isLoading else { return }
        self.isLoading = true
        self.currentUserStats = streakService.getCurrentUserStats()
        let habitsDescriptor = FetchDescriptor<Habit>()
        self.userHabits = dataManager.fetch(descriptor: habitsDescriptor)
        if userHabits.isEmpty {
            await createDefaultHabit()
        }
        self.isLoading = false
    }
    
    @MainActor
    private func createDefaultHabit() async {
        let defaultHabit = Habit(
            id: UUID(),
            name: "Daily Code Challenge",
            technology: Technology.swift.rawValue,
            difficulty: Difficulty.medium.rawValue
        )
        let userDescriptor = FetchDescriptor<User>()
        if let user = dataManager.fetch(descriptor: userDescriptor).first {
            defaultHabit.user = user
            dataManager.save(model: defaultHabit)
            await loadInitialData()
        } else {
            print("[ERROR] - User not found")
        }
    }
}
