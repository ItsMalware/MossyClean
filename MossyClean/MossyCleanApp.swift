import SwiftUI

@main
struct MossyCleanApp: App {
    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
