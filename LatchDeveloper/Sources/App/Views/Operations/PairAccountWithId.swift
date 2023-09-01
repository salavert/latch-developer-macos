import AppCenterAnalytics
import ComposableArchitecture
import LatchSharedModels
import SwiftUI

public struct PairAccountWithIdReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    public struct State: Equatable {
        @BindingState var id = ""
        var isPairingId = false
        
        var isSubmitButtonDisabled: Bool {
            id.count < 6
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case pair
        case pairSuccess
        case savePairedAccountId(String)
    }
    
    public enum DelegateAction: Equatable {
        case saveResponseLog(LatchResponse)
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
            case .pair:
                Analytics.trackEvent(Events.pairWithToken)
                state.isPairingId = true
                return .run { [id = state.$id.wrappedValue] send in
                    let latchResponse = try await networkClient.pairWithId(id)
                    await send(.delegate(.saveResponseLog(latchResponse)))
                    let pairAccountResponse = try? latchResponse.decodeAs(PairAccountResponse.self)
                    dump(pairAccountResponse)
                    if let error = pairAccountResponse?.error, error.code == 205, let accountId = pairAccountResponse?.data?.accountId {
                        await send(.savePairedAccountId(accountId))
                    }
                    if pairAccountResponse?.error == nil {
                        await send(.pairSuccess)
                    }
                }
                
            case .delegate(.saveResponseLog):
                state.isPairingId = false
                return .none
                
            case let .savePairedAccountId(accountId):
                var accounts = repositoryClient.getAccounts()
                if !accounts.contains(accountId) {
                    accounts.append(accountId)
                    repositoryClient.setAccounts(accounts)
                    dump(repositoryClient.getAccounts())
                }
                state.id = ""
                return .none
                
            case .pairSuccess:
                state.id = ""
                return .none
                
            case .delegate:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct PairAccountWithIdView: View {
    let store: StoreOf<PairAccountWithIdReducer>
    @ObservedObject var viewStore: ViewStore<PairAccountWithIdReducer.State, PairAccountWithIdReducer.Action>

    init(store: StoreOf<PairAccountWithIdReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    @State var id: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Start the pairing process by introducing a registered **email**. Once the process succeeds you should receive an alert notification on your device.")
                .headlineStyle()
            
            TextField("Email", text: viewStore.$id)
                .textFieldCustomStyle(backgroundColor: .white)
            
            Button(action: { viewStore.send(.pair) }, label: {
                HStack {
                    Spacer()
                    if viewStore.isPairingId {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Pair")
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .contentShape(Rectangle())
            })
            .buttonCustomStle()
            .padding(.top, 10)
            .disabled(viewStore.isSubmitButtonDisabled)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    PairAccountWithIdView(store: .init(initialState: PairAccountWithIdReducer.State()) {
        PairAccountWithIdReducer()
    })
}
