
import Foundation
import SwiftData

final class StreakService: StreakCalculator {
    private let dataManager: DataManaging
    private let rewardService: RewardGranting
    
    init(dataManager: DataManaging, rewardService: RewardGranting) {
        self.dataManager = dataManager
        self.rewardService = rewardService
    }
    
    func commitDailyQuest(habitID: UUID) -> CommitResult {
        guard let user = getSingleUser(),
              let habit = getHabit(by: habitID) else {
            return CommitResult(success: false, newStreak: 0, xpGained: 0, creditsGained: 0, livesLost: 0, isStreakBroken: true)
        }
        let today = Date().startOfDay()
        if habit.dailyRecords?.contains(where: { $0.date.startOfDay() == today }) == true {
            return createNoChangeResult(habit: habit)
        }
        var livesLost = 0
        var isStreakBroken = false
        var currentStreak = habit.currentStreak
        let lastCommitStartOfDay = habit.lastCommitDate?.startOfDay() ?? today.addingTimeInterval(-1)
        let daysPassed = today.daysSince(lastCommitStartOfDay)
        if daysPassed == 1 {
            currentStreak += 1
        } else if daysPassed > 1 {
            if user.lives > 0 {
                user.lives -= 1
                livesLost = 1
            } else {
                currentStreak = 1
                isStreakBroken = true
            }
        }
        let (xp, credits) = rewardService.calculateRewards(for: habit, currentStreak: currentStreak)
        let newRecord = DailyRecord(date: Date(), isCompleted: true, xpGained: xp, creditsGained: credits, habit: habit)
        if habit.dailyRecords == nil { habit.dailyRecords = [] }
        habit.dailyRecords?.append(newRecord)
        habit.currentStreak = currentStreak
        habit.lastCommitDate = Date()
        if currentStreak > habit.bestStreak {
            habit.bestStreak = currentStreak
        }
        user.totalXP += xp
        user.credits += credits
        if currentStreak > user.globalBestStreak {
            user.globalBestStreak = currentStreak
        }
        dataManager.update(model: habit)
        dataManager.update(model: user)
        return CommitResult(success: true, newStreak: currentStreak, xpGained: xp, creditsGained: credits,
                            livesLost: livesLost, isStreakBroken: isStreakBroken)
    }

    func getCurrentUserStats() -> UserStats? {
        guard let user = getSingleUser() else { return nil }
        return UserStats(level: user.level, totalXP: user.totalXP, credits: user.credits, lives: user.lives, globalBestStreak: user.globalBestStreak)
    }

    func purchaseLives(amount: Int) -> Bool {
        guard let user = getSingleUser() else { return false }
        let purchaseSuccessful = rewardService.purchaseLives(user: user, amount: amount)
        if purchaseSuccessful {
            dataManager.update(model: user)
        }
        return purchaseSuccessful
    }
        
    private func getSingleUser() -> User? {
        let descriptor = FetchDescriptor<User>()
        return dataManager.fetch(descriptor: descriptor).first
    }
    
    private func getHabit(by id: UUID) -> Habit? {
        let predicate = #Predicate <Habit> { $0.id == id }
        let descriptor = FetchDescriptor <Habit> (predicate: predicate)
        return dataManager.fetch(descriptor: descriptor).first
    }
    
    private func createNoChangeResult(habit: Habit) -> CommitResult {
        return CommitResult(success: false, newStreak: habit.currentStreak, xpGained: 0, creditsGained: 0,
                            livesLost: 0, isStreakBroken: false)
    }
}

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: self)
        let startOfTarget = calendar.startOfDay(for: date)
        guard let days = calendar.dateComponents([.day], from: startOfTarget, to: startOfToday).day else {
            return 0
        }
        return days
    }
}
