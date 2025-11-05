
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

    @Relationship(deleteRule: .cascade, inverse: \ActiveBooster.user)
    var activeBoosters: [ActiveBooster] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Habit.user)
    var habits: [Habit]?
    
    init(username: String, totalXP: Int, credits: Int, lives: Int, globalBestStreak: Int = 0) {
        self.username = username
        self.totalXP = totalXP
        self.credits = credits
        self.lives = lives
        self.globalBestStreak = globalBestStreak
        self.activeBoosters = []
    }
     
    var level: Int {
        return (totalXP / User.xpPerLevel) + 1
    }
    
    var xpForCurrentLevel: Int {
        return (level - 1) * User.xpPerLevel
    }

    var currentXP: Int {
        return totalXP % User.xpPerLevel
    }
    
    var xpToNextLevel: Int {
        let xpNeededForNextLevel = level * User.xpPerLevel
        return xpNeededForNextLevel - totalXP
    }
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
