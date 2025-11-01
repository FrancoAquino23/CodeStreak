
import Foundation

final class RewardService: RewardGranting {
    private let baseXP: Int = 50
    private let baseCredits: Int = 5
    private let lifeCost: Int = 100

    func calculateRewards(for habit: Habit, currentStreak: Int) -> (xp: Int, credits: Int) {
        let difficultyEnum = Difficulty(rawValue: habit.difficulty) ?? .medium
        let multiplier = difficultyEnum.xpMultiplier
        let rawXP = Double(baseXP) * multiplier
        let xpGained = Int(rawXP.rounded())
        let creditsGained = baseCredits
        
        return (xp: xpGained, credits: creditsGained)
    }
    
    func purchaseLives(user: User, amount: Int) -> Bool {
        guard amount > 0 else { return false }
        let totalCost = lifeCost * amount
        if user.credits >= totalCost {
            // 2. Aplicar la transacción
            user.credits -= totalCost
            user.lives += amount
            return true
        } else {
            return false
        }
    }
}
