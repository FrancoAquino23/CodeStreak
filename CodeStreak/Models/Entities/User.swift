
import Foundation
import SwiftData

@Model
final class User {
    var username: String
    var level: Int
    var totalXP: Int
    var credits: Int
    var lives: Int
    var globalBestStreak: Int
    
    @Relationship(deleteRule: .cascade) var habits: [Habit]?

    init(username: String = "Code Adventurer",
         level: Int = 1,
         totalXP: Int = 0,
         credits: Int = 100,
         lives: Int = 3,
         globalBestStreak: Int = 0,
         habits: [Habit]? = nil) {
             
        self.username = username
        self.level = level
        self.totalXP = totalXP
        self.credits = credits
        self.lives = lives
        self.globalBestStreak = globalBestStreak
        self.habits = habits
    }
}
