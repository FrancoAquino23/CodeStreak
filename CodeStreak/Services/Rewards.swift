
import Foundation

protocol RewardGranting: AnyObject {
    func calculateRewards(for habit: Habit, currentStreak: Int) -> (xp: Int, credits: Int)
    func purchaseLives(user: User, amount: Int) -> Bool
}
