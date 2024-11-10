import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = false // Track login status
    
    var body: some View {
        // Check if the user is logged in
        if isLoggedIn {
            // If logged in, show the tab view with Main, Profile, and Reward pages
            TabView {
                MainView()
                    .tabItem {
                        Image(systemName: "house.fill")  // Icon for Main tab
                            .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.0)) // Icon color
                        Text("Main")
                            .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.0)) // Text color
                    }
                    .tag(0)  // Tag for the Main tab

                ProfileDisplayView()
                    .tabItem {
                        Image(systemName: "person.fill") // Icon for Profile tab
                        Text("Profile")
                    }
                
                RewardView()
                    .tabItem {
                        Image(systemName: "star.fill") // Icon for Reward tab
                        Text("Reward")
                    }
            }
            .accentColor(Color(red: 0.85, green: 0.65, blue: 0.0)) // Accent color
        } else {
            // If not logged in, show the LoginView
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
