
import Foundation
import SwiftData

protocol RewardGranting: AnyObject {
    func calculateRewards(for habit: Habit, user: User, currentStreak: Int) -> (xp: Int, credits: Int)
    func purchaseBooster(user: User, type: BoosterType, durationMinutes: Double, cost: Int) -> Bool
    func purchaseLives(user: User, amount: Int) async -> Bool
}

final class RewardService: RewardGranting {
    private let baseXP: Int = 50
    private let baseCredits: Int = 5
    private let lifeCost: Int = 100
    private let dataManager: DataManaging
    
    init(dataManager: DataManaging) {
        self.dataManager = dataManager
    }
    
    func calculateRewards(for habit: Habit, user: User, currentStreak: Int) -> (xp: Int, credits: Int) {
        let difficultyEnum = Difficulty(rawValue: habit.difficulty) ?? .medium
        let difficultyMultiplier = difficultyEnum.xpMultiplier
        let streakBonus = 1.0 + (Double(currentStreak) * 0.01)
        let activeBoosters = user.activeBoosters.filter { $0.isActive }
        var xpBoostMultiplier: Double = 1.0
        var creditBoostMultiplier: Double = 1.0
        
        for booster in activeBoosters {
            switch booster.type {
                case .doubleXP: xpBoostMultiplier *= 2.0
                case .doubleCredits: creditBoostMultiplier *= 2.0
            }
        }
        
        let rawXP = Double(baseXP) * difficultyMultiplier * streakBonus * xpBoostMultiplier
        var xpGained = Int(rawXP.rounded())
        if xpGained < baseXP { xpGained = baseXP }
        let rawCredits = Double(baseCredits) * difficultyMultiplier * creditBoostMultiplier
        let creditsGained = Int(rawCredits.rounded())
        return (xp: xpGained, credits: creditsGained)
    }
    
    func purchaseLives(user: User, amount: Int) async -> Bool {
        let cost = amount * lifeCost
        guard user.credits >= cost else { return false }
        user.credits -= cost
        user.lives += amount
        await dataManager.update(model: user)
        return true
    }
    
    func purchaseBooster(user: User, type: BoosterType, durationMinutes: Double, cost: Int) -> Bool {
        guard user.credits >= cost else { return false }
        user.credits -= cost
        let newBooster = ActiveBooster(type: type, durationMinutes: durationMinutes)
        if let existingBooster = user.activeBoosters.first(where: { $0.type == type }) {
            let timeRemaining = max(0, existingBooster.expirationDate.timeIntervalSinceNow)
            let newDuration = timeRemaining + (durationMinutes * 60)
            existingBooster.expirationDate = Date().addingTimeInterval(newDuration)
        } else {
            user.activeBoosters.append(newBooster)
        }
        return true
    }
}
