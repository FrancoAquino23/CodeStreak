
import SwiftUI

@main
struct CodeStreakApp: App {
    let dataController = DataController()
    var persistenceManager: PersistenceManager {
        return PersistenceManager(context: dataController.getContext())
    }
    var rewardService: RewardGranting {
        return RewardService(dataManager: persistenceManager)
    }
    var streakService: StreakCalculator{
        return StreakService(dataManager: persistenceManager, rewardService: rewardService)
    }
    var homeViewModel: HomeViewModel {
        return HomeViewModel(streakService: streakService, dataManager: persistenceManager)
    }
    var profileViewModel: ProfileViewModel {
        return ProfileViewModel(dataManager: persistenceManager)
    }
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(homeViewModel)
                .environment(profileViewModel)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            StoreView()
                .tabItem {
                    Label("Store", systemImage: "cart.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
