
import SwiftUI
import SwiftData

@main
struct CodeStreakApp: App {
    
    @State private var modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: User.self, Habit.self, DailyRecord.self, ActiveBooster.self)
        } catch {
            fatalError("[ERROR] - Failed to create ModelContainer: \(error)")
        }
    }()
    private var dataStore: StoreData {
        return StoreData(container: modelContainer)
    }
    
    private var rewardService: RewardService {
        return RewardService(dataManager: dataStore)
    }
    
    private var streakService: StreakService {
        return StreakService(dataManager: dataStore, rewardService: rewardService)
    }
    
    private var questService: QuestService {
        return QuestService(dataManager: dataStore)
    }
    
    private var homeViewModel: HomeViewModel {
        return HomeViewModel(streakService: streakService, dataManager: dataStore)
    }
    
    private var profileViewModel: ProfileViewModel {
        return ProfileViewModel(dataManager: dataStore)
    }
    
    private var questsViewModel: QuestsViewModel {
        return QuestsViewModel(questService: questService, dataManager: dataStore)
    }

    private var storeViewModel: StoreViewModel {
        return StoreViewModel(rewardService: rewardService, dataManager: dataStore)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(storeViewModel: storeViewModel)
                .environment(homeViewModel)
                .environment(profileViewModel)
                .environment(questsViewModel)
        }
        .modelContainer(modelContainer)
    }
}

struct MainTabView: View {
    @State var storeViewModel: StoreViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            
            QuestsView()
                .tabItem { Label("Quests", systemImage: "target") }
            
            StoreView(storeViewModel: storeViewModel)
                .tabItem { Label("Store", systemImage: "bag") }
                
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
