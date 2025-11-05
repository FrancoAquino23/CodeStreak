
import Foundation
import SwiftData

actor PersistenceManager: DataManaging {
    private let modelContainer: ModelContainer
    private let context: ModelContext

    init(container: ModelContainer) {
        self.modelContainer = container
        self.context = ModelContext(container)
    }
    
    func fetch <T: PersistentModel> (descriptor: FetchDescriptor <T> ) async -> [T] {
        do {
            return try context.fetch(descriptor)
        } catch {
            print("[ERROR] - Failed to fetch \(T.self) with descriptor: \(error)")
            return []
        }
    }

    func fetch <T: PersistentModel> (predicate: Predicate <T> ) async -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return await fetch(descriptor: descriptor)
    }
    
    func save <T: PersistentModel> (model: T) async {
        context.insert(model)
        await saveContext()
    }
    
    func update <T: PersistentModel> (model: T) async {
        await saveContext()
    }
    
    func delete <T: PersistentModel> (model: T) async {
        context.delete(model)
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
        let existingUsers = await self.fetchSingleUser()
        guard existingUsers == nil else { return }
        let newUser = User(username: "Code Adventurer", totalXP: 0, credits: 100, lives: 3, globalBestStreak: 0)
        await self.save(model: newUser)
    }
    
    private func saveContext() async {
        do {
            try context.save()
        } catch {
            print("[ERROR] - Failed to save ModelContext: \(error)")
        }
    }
}
