
import Foundation
import SwiftData

enum BoosterType: String, Codable, Hashable {
    case doubleXP = "doubleXP"
    case doubleCredits = "doubleCredits"
}

@Model
final class ActiveBooster {
    var type: BoosterType
    var expirationDate: Date
    var user: User?
    var isActive: Bool {
        return expirationDate > Date()
    }
    
    init(type: BoosterType, durationMinutes: Double) {
        self.type = type
        self.expirationDate = Date().addingTimeInterval(durationMinutes * 60)
    }
}

enum StoreAction {
    case purchaseLives(amount: Int)
    case purchaseBooster(type: BoosterType, durationMinutes: Double)
}

struct StoreItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let cost: Int
    let action: StoreAction
}
