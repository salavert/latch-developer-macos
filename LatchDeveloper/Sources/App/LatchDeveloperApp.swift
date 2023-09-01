import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
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
        configureAppCenter()
        store.send(.didFinishLaunching)
    }
}

private extension AppDelegate {
    /// The App Center SDK uploads logs in a batch of 50 and if the SDK doesn't have 50 logs to send, it will still send logs after 6 seconds (by default).
    /// There can be a maximum of three batches sent in parallel.
    /// The transmission interval can be changed: Analytics.transmissionInterval = 10000 (10 seconds)
    func configureAppCenter() {
        Analytics.enabled = true
        AppCenter.start(withAppSecret: ApplicationConstants.appCenterSecret, services: [
            Analytics.self,
            Crashes.self
        ])
    }
}
