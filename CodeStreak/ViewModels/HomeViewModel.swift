
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
    var currentChallenge: Challenge?
    var commitSuccess: Bool = false

    init(streakService: StreakCalculator, dataManager: DataManaging) {
        self.streakService = streakService
        self.dataManager = dataManager
        Task { @MainActor in
            await loadInitialData()
        }
    }
    
    func purchaseLives(amount: Int) async {
        guard amount > 0 else { return }
        let success = await streakService.purchaseLives(amount: amount)
        if success {
            await loadInitialData()
        }
    }

    @MainActor
    func generateChallenge(for habit: Habit) async {
        currentChallenge = nil
        commitSuccess = false
        guard let difficultyEnum = Difficulty(rawValue: habit.difficulty) else {
            print("[ERROR] - Invalid difficulty value for habit: \(habit.difficulty)")
            return
        }

        let mockChallenge = Challenge(
            title: "Add numbers \(habit.technology)",
            problemDescription: "¿Whats the answer of \(difficultyEnum.rawValue) + 5? (Only write number)",
            expectedAnswer: String(difficultyEnum.rawValue + 5),
            hint: "Correct answer is \(difficultyEnum.rawValue + 5)",
            technology: Technology(rawValue: habit.technology) ?? .swift,
            difficulty: difficultyEnum
        )
        currentChallenge = mockChallenge
    }
    
    @MainActor
    func submitAnswer(userAnswer: String, habitID: UUID) async -> CommitResult {
        guard let challenge = currentChallenge,
              let habit = await dataManager.fetchHabit(by: habitID)
        else {
            return CommitResult(success: false, message: "[ERROR] - Challenge", newStreak: 0, xpGained: 0, creditsGained: 0, livesLost: 0, isStreakBroken: false)
        }
        let cleanAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanExpected = challenge.expectedAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if cleanAnswer == cleanExpected {
            let result = await streakService.commitDailyQuest(habitID: habitID)
            lastCommitResult = result
            commitSuccess = true
            await loadInitialData()
            return result
        } else {
             return CommitResult(success: false, message: "¡Incorrect answer! Keep trying", newStreak: habit.currentStreak, xpGained: 0, creditsGained: 0, livesLost: 0, isStreakBroken: false)
        }
    }
    
    @MainActor
    func loadInitialData() async {
        await streakService.checkDailyStreaks()
        guard !isLoading else { return }
        self.isLoading = true
        self.currentUserStats = await streakService.getCurrentUserStats()
        let habitsDescriptor = FetchDescriptor<Habit>()
        self.userHabits = await dataManager.fetch(descriptor: habitsDescriptor)
        if currentUserStats == nil || userHabits.isEmpty {
            if currentUserStats == nil {
                await createDefaultUser() // Asegura que el usuario exista
            }
            if userHabits.isEmpty {
                await createDefaultHabit()
            }
            self.currentUserStats = await streakService.getCurrentUserStats()
            self.userHabits = await dataManager.fetch(descriptor: habitsDescriptor)
        }

        self.isLoading = false
    }
    
    @MainActor
    private func createDefaultHabit() async {
        let defaultHabit = Habit(name: "Daily Swift", technology: "Swift", difficulty: 1, currentStreak: 0, bestStreak: 0, lastCommitDate: nil)
        await dataManager.save(model: defaultHabit)
    }
    @MainActor
    private func createDefaultUser() async {
        let defaultUser = User(username: "Code Adventurer", totalXP: 0, credits: 100, lives: 3)
        await dataManager.save(model: defaultUser)
    }
}
