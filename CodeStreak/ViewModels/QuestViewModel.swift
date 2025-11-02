
import Foundation
import SwiftUI
import SwiftData

@Observable
final class QuestsViewModel {
    private let questService: QuestService
    private let dataManager: DataManaging
    
    var dailyQuests: [DailyQuest] = []
    var userAnswer: String = ""
    var commitResult: CommitResult?
    var isLoading: Bool = false

    init(questService: QuestService, dataManager: DataManaging) {
        self.questService = questService
        self.dataManager = dataManager
        loadDailyQuests()
    }
    
    func loadDailyQuests() {
        self.dailyQuests = questService.generateDailyQuests()
    }
    
    func submitAnswer(for quest: DailyQuest) async {
        guard !isLoading else { return }
        guard let index = dailyQuests.firstIndex(where: { $0.id == quest.id }) else { return }
        isLoading = true
        let result = await questService.completeQuest(userAnswer: userAnswer, quest: quest)
        if result.success {
            self.dailyQuests[index].isCompleted = true
        } else {
            self.dailyQuests[index].hasFailed = true
        }
        self.commitResult = result
        self.userAnswer = ""
        self.isLoading = false
    }
    
    func getCurrentUserStats() async -> UserStats? {
        guard let user = await dataManager.fetchSingleUser() else { return nil }
        let xpToNext = user.xpToNextLevel
        let currentXPInLevel = user.totalXP - user.xpForCurrentLevel
        return UserStats(level: user.level,
                         totalXP: user.totalXP,
                         credits: user.credits,
                         lives: user.lives,
                         globalBestStreak: user.globalBestStreak,
                         currentXP: currentXPInLevel,
                         xpToNextLevel: xpToNext)
    }
}
