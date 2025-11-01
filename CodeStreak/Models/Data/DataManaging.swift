
import Foundation
import SwiftData

protocol DataManaging: AnyObject {
    
    func fetch <T: PersistentModel> (descriptor: FetchDescriptor <T> ) async -> [T]
    
    func fetch <T: PersistentModel> (predicate: Predicate<T>) async -> [T]
    
    func save <T: PersistentModel> (model: T) async
    
    func update <T: PersistentModel> (model: T) async
    
    func delete <T: PersistentModel> (model: T) async
    
    func fetchSingleUser() async -> User?
    
    func fetchHabit(by id: UUID) async -> Habit?
    
    func initializeDefaultUser() async
}
