import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>

    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
        
    var body: some View {
        TabView(selection: viewStore.$selectedSettingsTab) {
            GeneralSettingsView(store: store)
                .tabItem {
                    Label("General", systemImage: "key")
                }
                .tag(SettingsTab.general)
            
            DeveloperSettingsView(store: store)
                .tabItem {
                    Label("Developer", systemImage: "exclamationmark.triangle")
                }
                .tag(SettingsTab.developer)
            
            BugsSettingsView(store: store)
                .tabItem {
                    Label("Bugs", systemImage: "ladybug")
                }
                .tag(SettingsTab.bugs)
        }
        .padding(20)
    }
}
