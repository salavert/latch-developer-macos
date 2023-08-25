import ComposableArchitecture
import SwiftUI

public struct ConfigurationReducer: Reducer {
    @Dependency(\.repositoryClient) var repositoryClient
    
    public struct State: Equatable {
        @BindingState var appId = ""
        @BindingState var appSecret = ""
        @BindingState var host = ""
        @BindingState var userId = ""
        @BindingState var userSecret = ""
        
        var isSubmitButtonDisabled: Bool {
            host.isEmpty || (!appIsDefined && !userIsDefined)
        }
        
        var appIsDefined: Bool {
            !appId.isEmpty && !appSecret.isEmpty
        }
        
        var userIsDefined: Bool {
            !userId.isEmpty && !userSecret.isEmpty
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case configure
        case onLoad
    }
    
    public enum DelegateAction: Equatable {
        case configure(ApplicationConfig)
    }
    
    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        self.core
    }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onLoad:
                let applicationConfig = repositoryClient.getApplicationConfig()
                state.appId = applicationConfig?.appId ?? ""
                state.appSecret = applicationConfig?.appSecret ?? ""
                state.host = applicationConfig?.host ?? ApplicationConstants.defaultHost
                state.userId = applicationConfig?.userId ?? ""
                state.userSecret = applicationConfig?.userSecret ?? ""
                return .none
                
            case .configure:
                return .send(.delegate(.configure(.init(
                    appId: state.appId,
                    appSecret: state.appSecret,
                    host: state.host,
                    userId: !state.userId.isEmpty ? state.userId : nil,
                    userSecret: !state.userSecret.isEmpty ? state.userSecret : nil
                ))))
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

struct ConfigurationView: View {
    @State var appId = ""
    @State var appSecret = ""
    @State var host = ""
    @State var userId = ""
    @State var userSecret = ""
    
    let store: StoreOf<ConfigurationReducer>
    @ObservedObject var viewStore: ViewStore<ConfigurationReducer.State, ConfigurationReducer.Action>

    init(store: StoreOf<ConfigurationReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Application details:")
                .headlineStyle()
                .padding(.top, 10)
            
            TextField("Application ID", text: viewStore.$appId)
                .textFieldConfigStyle()
            
            TextField("Application Secret", text: viewStore.$appSecret)
                .textFieldConfigStyle()
            
            TextField("Host address", text: viewStore.$host)
                .textFieldConfigStyle()
            
            Text("API User details:")
                .headlineStyle()
            
            TextField("User ID", text: viewStore.$userId)
                .textFieldConfigStyle()
            
            TextField("User Secret", text: viewStore.$userSecret)
                .textFieldConfigStyle()
            
            Button(action: { viewStore.send(.configure) }, label: {
                HStack {
                    Spacer()
                    Text("Configure")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .contentShape(Rectangle()) 
            })
            .buttonCustomStle()
            .padding(.top, 10)
            .disabled(viewStore.isSubmitButtonDisabled)
        }
        .onLoad() { viewStore.send(.onLoad) }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ConfigurationView(store: Store(initialState: ConfigurationReducer.State()) {
        ConfigurationReducer()
    })
}
