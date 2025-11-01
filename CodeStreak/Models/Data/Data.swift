
import Foundation
import SwiftData

final class DataController {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        let schema = Schema([User.self, Habit.self, DailyRecord.self])
        let config = ModelConfiguration("CodeStreakDB", schema: schema)
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
            self.modelContext = modelContainer.mainContext
        } catch {
            fatalError ("[ERROR] - Could not create container: \(error)")
        }
        self.initializeDefaultUser()
    }

    func fetch <T: PersistentModel> (descriptor: FetchDescriptor <T> ) -> [T] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("[ERROR] - Fetching \(T.self): \(error)")
            return []
        }
    }
    
    func save <T: PersistentModel> (model: T) {
        modelContext.insert(model)
        do {
            try modelContext.save()
        } catch {
            print("[ERROR] - Saving context: \(error)")
        }
    }

    private func initializeDefaultUser() {
        let descriptor = FetchDescriptor <User> ()
        let existingUsers = self.fetch(descriptor: descriptor)
        guard existingUsers.isEmpty else { return }
        let newUser = User(
            username: "Code Adventurer", totalXP: 0, credits: 100, lives: 3, globalBestStreak: 0)
        self.save(model: newUser)
        print("User initialized successfully")
    }

    func getContext() -> ModelContext {
        return modelContext
    }
}
