import SwiftUI

@main
struct MossyCleanApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
