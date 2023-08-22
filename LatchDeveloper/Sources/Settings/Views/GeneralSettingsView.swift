import ComposableArchitecture
import SwiftUI

struct GeneralSettingsView: View {
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    
    @AppStorage("com.tef.app.appId") private var appId = ""
    @AppStorage("com.tef.app.appSecret") private var appSecret = ""
    @AppStorage("com.tef.app.userId") private var userId = ""
    @AppStorage("com.tef.app.userSecret") private var userSecret = ""
    @AppStorage("com.tef.app.host") private var host = ""
    
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>

    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        Form {
            Section {
                TextField("User Id", text: $userId)
                    .textFieldStyle(.roundedBorder)
                SecureField("User Secret", text: $userSecret)
                    .textFieldStyle(.roundedBorder)
            } header: {
                Text("API User:")
                    .font(.headline)
            }

            Divider()
                .padding(.vertical, 5)            
            
            Section {
                TextField("Id", text: $appId)
                    .textFieldStyle(.roundedBorder)
                SecureField("Secret", text: $appSecret)
                    .textFieldStyle(.roundedBorder)
            } header: {
                Text("Application:")
                    .font(.headline)
            }

            Divider()
                .padding(.vertical, 5)

            Section {
                TextField("Host", text: $host)
                    .textFieldStyle(.roundedBorder)
            } header: {
                Text("Host address:")
                    .font(.headline)
            }
            Spacer()
        }
        .padding(20)
        .frame(width: 460, height: 250)
        .onChange(of: appId) { _ in viewStore.send(.generalSettingsChanged) }
        .onChange(of: appSecret) { _ in viewStore.send(.generalSettingsChanged) }
        .onChange(of: userId) { _ in viewStore.send(.generalSettingsChanged) }
        .onChange(of: userSecret) { _ in viewStore.send(.generalSettingsChanged) }
        .onChange(of: host) { _ in viewStore.send(.generalSettingsChanged) }
    }
}

