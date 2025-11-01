
import Foundation
import SwiftData

protocol RewardGranting: AnyObject {
    
    func calculateRewards(for habit: Habit, currentStreak: Int) -> (xp: Int, credits: Int)

    func purchaseLives(user: User, amount: Int) async -> Bool
}

final class CreditService: RewardGranting {
    private let BASE_XP_PER_COMMIT = 50
    private let BASE_CREDITS_PER_COMMIT = 10
    private let COST_OF_ONE_LIFE = 50
    private let dataManager: DataManaging
    
    init(dataManager: DataManaging) {
        self.dataManager = dataManager
    }
    
    func calculateRewards(for habit: Habit, currentStreak: Int) -> (xp: Int, credits: Int) {
        guard let difficultyEnum = Difficulty(rawValue: habit.difficulty) else {
            return (xp: BASE_XP_PER_COMMIT, credits: BASE_CREDITS_PER_COMMIT)
        }
        let difficultyMultiplier = difficultyEnum.xpMultiplier
        let streakBonus = 1.0 + (Double(currentStreak) * 0.01)
        var xp = Int(Double(BASE_XP_PER_COMMIT) * difficultyMultiplier * streakBonus)
        let credits = Int(Double(BASE_CREDITS_PER_COMMIT) * difficultyMultiplier)
        if xp < BASE_XP_PER_COMMIT { xp = BASE_XP_PER_COMMIT }
        return (xp: xp, credits: credits)
    }
    
    func purchaseLives(user: User, amount: Int) async -> Bool {
        let cost = amount * COST_OF_ONE_LIFE
        guard user.credits >= cost else {
            return false
        }
        user.credits -= cost
        user.lives += amount
        await dataManager.update(model: user)
        return true
    }
}
