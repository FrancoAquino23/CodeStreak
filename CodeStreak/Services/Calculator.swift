
import Foundation

protocol StreakCalculator: AnyObject {

    func commitDailyQuest(habitID: UUID) async -> CommitResult
    
    func checkDailyStreaks() async

    func getCurrentUserStats() async -> UserStats?
    
    func purchaseLives(amount: Int) async -> Bool
}

struct CommitResult {
    let success: Bool
    let message: String
    let newStreak: Int
    let xpGained: Int
    let creditsGained: Int
    let livesLost: Int
    let isStreakBroken: Bool
}

struct UserStats {
    let level: Int
    let totalXP: Int
    let credits: Int
    let lives: Int
    let globalBestStreak: Int
    let currentXP: Int
    let xpToNextLevel: Int
}
