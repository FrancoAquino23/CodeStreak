
import Foundation
import SwiftData

final class StoreData: DataManaging {
    private let modelContainer: ModelContainer
    private var mainContext: ModelContext {
        return modelContainer.mainContext
    }

    init(container: ModelContainer) {
        self.modelContainer = container
    }
    
    func fetch <T: PersistentModel> (descriptor: FetchDescriptor <T> ) async -> [T] {
        do {
            return try mainContext.fetch(descriptor)
        } catch {
            print("[ERROR] - Fetching \(T.self): \(error.localizedDescription)")
            return []
        }
    }

    func fetch <T: PersistentModel> (predicate: Predicate <T> ) async -> [T] {
        let descriptor = FetchDescriptor <T> (predicate: predicate)
        return await fetch(descriptor: descriptor)
    }
    
    func save <T: PersistentModel> (model: T) async {
        mainContext.insert(model)
        await saveContext()
    }
    
    func update <T: PersistentModel> (model: T) async {
        await saveContext()
    }

    func delete <T: PersistentModel> (model: T) async {
        mainContext.delete(model)
        await saveContext()
    }
    
    func fetchSingleUser() async -> User? {
        let descriptor = FetchDescriptor<User>()
        return await fetch(descriptor: descriptor).first
    }

    func fetchHabit(by id: UUID) async -> Habit? {
        let predicate = #Predicate<Habit> { $0.id == id }
        return await fetch(predicate: predicate).first
    }

    func initializeDefaultUser() async {
        let user = await fetchSingleUser()
        if user == nil {
            let defaultUser = User(username: "CodeAdventurer", totalXP: 0, credits: 100, lives: 3)
            await save(model: defaultUser)
            print("Default user created")
        }
    }

    private func saveContext() async {
        do {
            try mainContext.save()
        } catch {
            print("[ERROR] - Saving context: \(error.localizedDescription)")
        }
    }
}
