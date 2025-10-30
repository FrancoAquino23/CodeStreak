
import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var technology: String
    var difficulty: Int
    var currentStreak: Int
    var bestStreak: Int
    var lastCommitDate: Date?
    var user: User?

    @Relationship(deleteRule: .cascade) var dailyRecords: [DailyRecord]?

    init(id: UUID = UUID(), name: String = "", technology: String = "Swift", difficulty: Int = 1, currentStreak: Int = 0,
         bestStreak: Int = 0, lastCommitDate: Date? = nil, user: User? = nil, dailyRecords: [DailyRecord]? = nil) {
        self.id = id
        self.name = name
        self.technology = technology
        self.difficulty = difficulty
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.lastCommitDate = lastCommitDate
        self.user = user
        self.dailyRecords = dailyRecords
    }
}
