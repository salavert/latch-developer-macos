import ComposableArchitecture
import SwiftUI

struct NavigationView: View {
    @Environment(\.openURL) private var openURL

    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>

    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationSplitView {
            List(MenuOption.allCases.filter({ !$0.disabled }), id: \.self, selection: viewStore.$selectedMenuOption) { option in
                NavigationLink(value: option) {
                    Image(systemName: option.icon)
                    Text(option.title)
                }
                .disabled(option.disabled)
            }
            Image("big-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 100, maxHeight: 100)
                .padding(.horizontal, 20)
            
            Text("Beta version \(ApplicationConstants.appVersion) (\(ApplicationConstants.buildNumber))")
                .footnoteStyle()
            
            if let newVersionTag = viewStore.newVersionTag {
                Button(action: { openURL(ApplicationConstants.appCenterPublicGroupURL) }) {
                    Text("New version **\(newVersionTag)** available")
                        .featuredStyle()
                }
                .help("Click to download new version")
            }
            
            Spacer()
        } detail: {
           switch viewStore.$selectedMenuOption.wrappedValue {
            case .pair:
               PairAccountView(store: store)
            case .unpair:
               IfLetStore(
                   store.scope(state: \.unpairAccount, action: AppReducer.Action.unpairAccount),
                   then: UnpairAccountView.init
               )
            case .status:
               StatusView(store: store)
            case .operations:
               OperationsView(store: store)
            case .applications:
               IfLetStore(
                   store.scope(state: \.applications, action: AppReducer.Action.applications),
                   then: ApplicationsView.init
               )
            case .subscription:
               IfLetStore(
                   store.scope(state: \.subscription, action: AppReducer.Action.subscription),
                   then: SubscriptionView.init
               )
            case .userHistory:
               IfLetStore(
                   store.scope(state: \.userHistory, action: AppReducer.Action.userHistory),
                   then: UserHistoryView.init
               )
            case .logs:
                LogsView(store: store)
            default:
                Text(viewStore.selectedMenuOption.title)
                    .navigationTitle(viewStore.selectedMenuOption.title)
            }   
        }
        .navigationTitle(viewStore.selectedMenuOption.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewStore.send(.presentConfiguration) }) {
                    Image(systemName: "gearshape")
                }
                .help("Configure you application and user Id/Secret")
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewStore.send(.presentBugs) }) {
                    Image(systemName: "ladybug")
                }
                .help("Report a bug")
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewStore.send(.copyToClipboardPresentedLog) }) {
                    Image(systemName: "doc.on.doc")
                }
                .disabled(viewStore.isCopyToClipboardDisabled)
                .help("Copy to clipboard the response log")
            }  
        }
    }
}

#Preview {
    NavigationView(store: .init(initialState: AppReducer.State()) {
        AppReducer()
    })
}
