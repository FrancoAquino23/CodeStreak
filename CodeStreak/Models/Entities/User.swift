
import Foundation
import SwiftData

@Model
final class User: Sendable {
    private static let xpPerLevel: Int = 1000
    var id: UUID = UUID()
    var username: String
    var totalXP: Int
    var credits: Int
    var lives: Int
    var globalBestStreak: Int
    
    @Relationship(deleteRule: .cascade)
    var habits: [Habit]?

    init(username: String, totalXP: Int, credits: Int, lives: Int, globalBestStreak: Int = 0) {
        self.username = username
        self.totalXP = totalXP
        self.credits = credits
        self.lives = lives
        self.globalBestStreak = globalBestStreak
    }
    var level: Int {
        return (totalXP / User.xpPerLevel) + 1
    }
    var xpForCurrentLevel: Int {
        return (level - 1) * User.xpPerLevel
    }
    var xpToNextLevel: Int {
        let xpNeededForNextLevel = level * User.xpPerLevel
        return xpNeededForNextLevel - (totalXP - xpForCurrentLevel)
    }
}
