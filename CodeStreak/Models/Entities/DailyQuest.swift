
import Foundation

struct DailyQuest: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let answer: String
    let hint: String?
    let rewardXP: Int
    let rewardCredits: Int
    var isCompleted: Bool = false
    var hasFailed: Bool = false
}
