
import Foundation
import SwiftData

final class StreakService: StreakCalculator {
    private let dataManager: DataManaging
    private let rewardService: RewardGranting
    
    init(dataManager: DataManaging, rewardService: RewardGranting) {
        self.dataManager = dataManager
        self.rewardService = rewardService
    }

    func commitDailyQuest(habitID: UUID) async -> CommitResult {
        guard let user = await getSingleUser(),
              let habit = await getHabit(by: habitID) else {
            return CommitResult(success: false, message: "[ERROR] - User or Habit not found",
                                newStreak: 0, xpGained: 0, creditsGained: 0, livesLost: 0, isStreakBroken: false)
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
        
        let (xp, credits) = rewardService.calculateRewards(for: habit, user: user, currentStreak: currentStreak)
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
        await dataManager.update(model: habit)
        await dataManager.update(model: user)
        let message = livesLost > 0 ? "Streak saved! 1 life lost" : "+\(xp) XP, +\(credits) Credits"
        return CommitResult(success: true, message: message, newStreak: currentStreak, xpGained: xp, creditsGained: credits,
                            livesLost: livesLost, isStreakBroken: isStreakBroken)
    }

    func checkDailyStreaks() async {
        guard let user = await getSingleUser() else { return }
        let habits = await getHabitsFor(user: user)
        let today = Date().startOfDay()
        for habit in habits {
            guard let lastCommit = habit.lastCommitDate else { continue }
            let daysPassed = today.daysSince(lastCommit.startOfDay())
            if daysPassed > 1 {
                if user.lives > 0 {
                    user.lives -= 1
                } else {
                    habit.currentStreak = 0
                }
                await dataManager.update(model: habit)
            }
        }
        await dataManager.update(model: user)
    }
    
    func getCurrentUserStats() async -> UserStats? {
        guard let user = await dataManager.fetchSingleUser() else { return nil }
        let xpToNext = user.xpToNextLevel
        let currentXPInLevel = user.totalXP - user.xpForCurrentLevel
        return UserStats(level: user.level, totalXP: user.totalXP, credits: user.credits, lives: user.lives, globalBestStreak: user.globalBestStreak, currentXP: currentXPInLevel, xpToNextLevel: xpToNext)
    }
    
    func purchaseLives(amount: Int) async -> Bool {
        guard let user = await dataManager.fetchSingleUser() else { return false }
        let purchaseSuccessful = await rewardService.purchaseLives(user: user, amount: amount)
        if purchaseSuccessful {
            await dataManager.update(model: user)
        }
        return purchaseSuccessful
    }
    
    private func getSingleUser() async -> User? {
        return await dataManager.fetchSingleUser()
    }
    
    private func getHabit(by id: UUID) async -> Habit? {
        return await dataManager.fetchHabit(by: id)
    }

    private func getHabitsFor(user: User) async -> [Habit] {
        let userID = user.persistentModelID
        return await dataManager.fetch(predicate: #Predicate<Habit> { $0.user?.persistentModelID == userID })
    }
    
    private func createNoChangeResult(habit: Habit) -> CommitResult {
        return CommitResult(success: false, message: "You already completed todays challenge",
                            newStreak: habit.currentStreak, xpGained: 0, creditsGained: 0,
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
