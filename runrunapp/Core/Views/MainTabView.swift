import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            // Tab 1: Home/Feed
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }

            // Tab 2: Friends
            FriendsView()
                .tabItem {
                    Label("Amigos", systemImage: "person.2.fill")
                }

            // Tab 3: Run (principal)
            RunTrackingView()
                .tabItem {
                    Label("Correr", systemImage: "figure.run.circle.fill")
                }

            // Tab 4: Groups
            GroupListView()
                .tabItem {
                    Label("Grupos", systemImage: "person.3.fill")
                }

            // Tab 5: Profile
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle.fill")
                }
        }
        .tint(.cyan)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [User.self, Run.self])
}
