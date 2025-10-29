
import Foundation

protocol StreakCalculator: AnyObject {
    func commitDailyQuest(habitID: UUID) -> CommitResult
    func getCurrentUserStats() -> UserStats?
    func purchaseLives(amount: Int) -> Bool
}

struct CommitResult {
    let success: Bool
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
}
