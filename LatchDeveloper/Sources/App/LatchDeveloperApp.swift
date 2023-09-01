import AppKit
import ComposableArchitecture
import SwiftUI

@main
struct LatchDeveloperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup(id: "config") {
            AppView(store: appDelegate.store)
                .preferredColorScheme(.light)
        }
        .defaultPosition(.center)
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView(store: appDelegate.store)
        }
        .defaultPosition(.center)
    }
}

// MARK: NSApplicationDelegate

final class AppDelegate: NSObject, NSApplicationDelegate {
    let store =  Store(initialState: AppReducer.State()) {
        AppReducer()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Log.enable()
        store.send(.didFinishLaunching)
    }
}
