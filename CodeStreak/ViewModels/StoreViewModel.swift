
import Foundation
import SwiftData
import Combine

final class StoreViewModel: ObservableObject {
    @Published var currentUser: User?
    
    private let rewardService: RewardGranting
    private let dataManager: DataManaging
    
    init(rewardService: RewardGranting, dataManager: DataManaging) {
        self.rewardService = rewardService
        self.dataManager = dataManager
        Task {
            await fetchCurrentUser()
        }
    }
    let availableItems: [StoreItem] = [
        StoreItem(
            name: "Extra Life",
            description: "Safe your streak",
            iconName: "heart.fill",
            cost: 100,
            action: .purchaseLives(amount: 1)
        ),
        StoreItem(
            name: "Double XP",
            description: "Get double XP for 20 minutes",
            iconName: "flame.fill",
            cost: 50,
            action: .purchaseBooster(type: .doubleXP, durationMinutes: 20)
        ),
        StoreItem(
            name: "Double Credits",
            description: "Multipliy your credits for 20 minutes",
            iconName: "creditcard.fill",
            cost: 30,
            action: .purchaseBooster(type: .doubleCredits, durationMinutes: 20)
        )
    ]

    func purchaseItem(item: StoreItem) async -> Bool {
        guard let user = currentUser, user.credits >= item.cost else {
            return false
        }
        let purchaseSuccessful: Bool
        switch item.action {
        case .purchaseLives(let amount):
            purchaseSuccessful = await rewardService.purchaseLives(user: user, amount: amount)
    
        case .purchaseBooster(let type, let duration):
            purchaseSuccessful = rewardService.purchaseBooster(
                user: user,
                type: type,
                durationMinutes: duration,
                cost: item.cost
            )
            if purchaseSuccessful {
                await dataManager.update(model: user)
            }
        }
        await fetchCurrentUser()
        return purchaseSuccessful
    }
    
    @MainActor
    private func fetchCurrentUser() async {
        self.currentUser = await dataManager.fetchSingleUser()
    }
}
