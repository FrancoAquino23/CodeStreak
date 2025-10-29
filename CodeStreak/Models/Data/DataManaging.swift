
import Foundation
import SwiftData

protocol DataManaging: AnyObject {
    
    func fetch <T: PersistentModel> (descriptor: FetchDescriptor <T> ) -> [T]
    
    func save <T: PersistentModel> (model: T)
    
    func update <T: PersistentModel> (model: T)
    
    func delete <T: PersistentModel> (model: T)
    
    func initializeDefaultUser()
}
