
import Foundation

protocol StreakCalculator: AnyObject {

    func commitDailyQuest(habitID: UUID) async -> CommitResult
    
    func checkDailyStreaks() async

    func getCurrentUserStats() async -> UserStats?
    
    func purchaseLives(amount: Int) async -> Bool
}

struct CommitResult: Equatable {
    let success: Bool
    let message: String
    let newStreak: Int
    let xpGained: Int
    let creditsGained: Int
    let livesLost: Int
    let isStreakBroken: Bool
}
