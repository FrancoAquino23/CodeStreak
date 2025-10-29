
import Foundation
import SwiftUI
import SwiftData

// MARK: - Presentation Structs

struct Achievement {
    let name: String
    let description: String
    let isUnlocked: Bool
    let requiredStreak: Int
}

@Observable
final class ProfileViewModel {
    private let dataManager: DataManaging
    var user: User?
    var habitsSummary: [(name: String, bestStreak: Int)] = []
    var achievements: [Achievement] = []
    var isLoading: Bool = false
    
    init(dataManager: DataManaging) {
        self.dataManager = dataManager
        loadProfileData()
    }
    
    func loadProfileData() {
        self.isLoading = true
        let userDescriptor = FetchDescriptor <User> ()
        self.user = dataManager.fetch(descriptor: userDescriptor).first
        guard let currentUser = self.user else {
            self.isLoading = false
            return
        }
        let habitsDescriptor = FetchDescriptor<Habit>()
        let allHabits = dataManager.fetch(descriptor: habitsDescriptor)
        self.habitsSummary = allHabits.map { habit in
            (name: habit.name, bestStreak: habit.bestStreak)
        }
        self.achievements = calculateAchievements(for: currentUser)
        self.isLoading = false
    }

    private func calculateAchievements(for user: User) -> [Achievement] {
        let globalBestStreak = user.globalBestStreak
        let allPossibleAchievements = [
            Achievement(name: "The Novice",
                        description: "Complete your first 3 - day streak",
                        isUnlocked: globalBestStreak >= 3,
                        requiredStreak: 3),
            Achievement(name: "The Consistent",
                        description: "Achieve a 7 - day streak",
                        isUnlocked: globalBestStreak >= 7,
                        requiredStreak: 7),
            Achievement(name: "The Habit Former",
                        description: "Achieve a 21 - day streak",
                        isUnlocked: globalBestStreak >= 21,
                        requiredStreak: 21),
            Achievement(name: "The Immortal",
                        description: "Reach a 50 - day streak",
                        isUnlocked: globalBestStreak >= 50,
                        requiredStreak: 50)
        ]
        return allPossibleAchievements
    }
}
