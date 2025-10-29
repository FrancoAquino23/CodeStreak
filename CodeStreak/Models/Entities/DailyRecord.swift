
import Foundation
import SwiftData

@Model
final class DailyRecord {
    var date: Date
    var isCompleted: Bool
    var xpGained: Int
    var creditsGained: Int
    var habit: Habit?

    init(date: Date = Date(), isCompleted: Bool = false, xpGained: Int = 0, creditsGained: Int = 0, habit: Habit? = nil) {
        self.date = date
        self.isCompleted = isCompleted
        self.xpGained = xpGained
        self.creditsGained = creditsGained
        self.habit = habit
    }
}
