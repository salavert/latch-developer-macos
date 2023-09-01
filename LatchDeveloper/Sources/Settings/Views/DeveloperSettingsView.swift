import AppCenterAnalytics
import ComposableArchitecture
import SwiftUI

struct DeveloperSettingsView: View {
    @Dependency(\.repositoryClient) var repositoryClient
    
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>

    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10){
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundStyle(.red)

            Text("This will reset all stored data like application and user configurations, paired account ids and operation ids.")
                .font(.headline)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)

            Button("Delete") {
                Analytics.trackEvent(Events.clearAllData)
                repositoryClient.clearAll()
            }
            .buttonCustomStle()
        }
        .padding(20)
        .frame(width: 460, height: 170)
    }
}

#Preview {
    DeveloperSettingsView(store: .init(initialState: AppReducer.State()) {
        AppReducer()
    })
}
