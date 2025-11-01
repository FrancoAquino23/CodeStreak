
import SwiftUI
import SwiftData

@main
struct CodeStreakApp: App {
    @State private var modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: User.self, Habit.self, DailyRecord.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    private var dataStore: SwiftDataStore {
        return SwiftDataStore(container: modelContainer)
    }
    
    private var rewardService: RewardService {
        return RewardService()
    }
    
    private var streakService: StreakService {
        return StreakService(dataManager: dataStore, rewardService: rewardService)
    }
    
    private var homeViewModel: HomeViewModel {
        return HomeViewModel(streakService: streakService, dataManager: dataStore)
    }
    
    private var profileViewModel: ProfileViewModel {
        return ProfileViewModel(dataManager: dataStore)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(homeViewModel)
                .environment(profileViewModel)
        }
        .modelContainer(modelContainer)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            StoreView()
                .tabItem { Label("Store", systemImage: "bag") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
