
import Foundation
import SwiftData

final class QuestService {
    private let dataManager: DataManaging

    init(dataManager: DataManaging) {
        self.dataManager = dataManager
    }
    
    func generateDailyQuests() -> [DailyQuest] {
        return [
            DailyQuest(question: "What programming language uses 'let' and 'var' sintaxis?",
                       answer: "Swift",
                       hint: "",
                       rewardXP: 10,
                       rewardCredits: 5),
            
            DailyQuest(question: "What does HTML stands for?",
                       answer: "HyperText Markup Language",
                       hint: "",
                       rewardXP: 15,
                       rewardCredits: 10),
            
            DailyQuest(question: "¿Which key concept allows an object take many posible forms in POO?",
                       answer: "Polymorphism",
                       hint: "Empieza con P.",
                       rewardXP: 20,
                       rewardCredits: 15)
        ]
    }

    func completeQuest(userAnswer: String, quest: DailyQuest) async -> CommitResult {
        guard let user = await dataManager.fetchSingleUser() else {
            return CommitResult(success: false, message: "[ERROR] - User not found", newStreak: 0, xpGained: 0,
                                creditsGained: 0, livesLost: 0, isStreakBroken: false)
        }
        let trimmedAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmedAnswer == quest.answer.lowercased() {
            user.totalXP += quest.rewardXP
            user.credits += quest.rewardCredits
            await dataManager.update(model: user)
            return CommitResult(success: true,
                                message: "¡Correct! +\(quest.rewardXP) XP, +\(quest.rewardCredits) Credits",
                                newStreak: 0, xpGained: quest.rewardXP, creditsGained: quest.rewardCredits, livesLost: 0, isStreakBroken: false)
        } else {
            let failureMessage = "¡Incorrect! Mision Failed. \n\nRight answer was: **\(quest.answer)**."
            return CommitResult(success: false,
                                message: failureMessage, newStreak: 0, xpGained: 0, creditsGained: 0, livesLost: 0, isStreakBroken: false)
        }
    }
}
