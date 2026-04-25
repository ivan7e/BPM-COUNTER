import SwiftUI
import SwiftData

@main
struct BPM_CounterApp: App {
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                BPMHomeView()
            } else {
                LoginView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
