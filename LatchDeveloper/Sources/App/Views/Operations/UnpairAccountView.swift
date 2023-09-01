import ComposableArchitecture
import LatchSharedModels
import SwiftUI

public struct UnpairAccountReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    public struct State: Equatable {
        var pairedAccounts: [String]
        var isUnpairingToken: Bool
        var isPickerDisabled: Bool
        
        @BindingState var selectedAccountId = ""
        @BindingState var manualAccountId = ""
        
        init(
            pairedAccounts: [String] = [],
            isUnpairingToken: Bool = false,
            isPickerDisabled: Bool = false
        ) {
            self.pairedAccounts = pairedAccounts
            self.isUnpairingToken = isUnpairingToken
            self.isPickerDisabled = isPickerDisabled
        }
        
        var isSubmitButtonDisabled: Bool {
            selectedAccountId.isEmpty && manualAccountId.isEmpty
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case onLoad
        case unpair
        case deletePairedAccountId(String)
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
            case .onLoad:
                state.pairedAccounts = repositoryClient.getAccounts()
                return .none
                
            case .unpair:
                state.isUnpairingToken = true
                var accountId: String
                if !state.selectedAccountId.isEmpty {
                    accountId = state.selectedAccountId
                } else {
                    accountId = state.manualAccountId
                }
                return .run { [accountId = accountId] send in
                    let latchResponse = try await networkClient.unpair(accountId)
                    await send(.delegate(.saveResponseLog(latchResponse)))
                    let genericResponseWithError = try? latchResponse.decodeAs(UnpairAccountResponse.self)
                    if let error = genericResponseWithError?.error, error.code == 201 {
                        await send(.deletePairedAccountId(accountId))
                    } else if genericResponseWithError?.error == nil {
                        await send(.deletePairedAccountId(accountId))
                    }
                }
                
            case .delegate(.saveResponseLog):
                state.isUnpairingToken = false
                return .none
                
            case let .deletePairedAccountId(accountId):
                var pairedAccounts = repositoryClient.getAccounts()
                pairedAccounts.removeAll(where: { $0 == accountId })
                repositoryClient.setAccounts(pairedAccounts)
                dump(repositoryClient.getAccounts())
                state.pairedAccounts = pairedAccounts
                state.selectedAccountId = ""
                state.manualAccountId = ""
                return .none
                
            case .binding(\.$manualAccountId):
                if !state.manualAccountId.isEmpty {
                    state.selectedAccountId = ""
                    state.isPickerDisabled = true
                } else {
                    state.isPickerDisabled = false
                }
                return .none
                
            case .delegate:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct UnpairAccountView: View {
    let store: StoreOf<UnpairAccountReducer>
    @ObservedObject var viewStore: ViewStore<UnpairAccountReducer.State, UnpairAccountReducer.Action>

    init(store: StoreOf<UnpairAccountReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !viewStore.pairedAccounts.isEmpty {
                Text("Select one of the following paired Account Ids:")
                    .headlineStyle()
                
                Picker(selection: viewStore.$selectedAccountId) {
                    ForEach(viewStore.pairedAccounts.reversed(), id: \.self) {
                        Text($0).truncationMode(.middle)
                            .lineLimit(1)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
                .disabled(viewStore.isPickerDisabled)
                
                Text("Or specify one manually:")
                    .headlineStyle()
            } else {
                Text("Specify the Account Id to unpair:")
                    .headlineStyle()
            }
            
            TextField("Account Id", text: viewStore.$manualAccountId)
                .textFieldCustomStyle()

            Button(action: { viewStore.send(.unpair) }, label: {
                HStack {
                    Spacer()
                    if viewStore.isUnpairingToken {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Unpair")
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
        .onLoad { viewStore.send(.onLoad) }
        .padding()
    }
}

#Preview {
    UnpairAccountView(store: .init(initialState: UnpairAccountReducer.State()) {
        UnpairAccountReducer()
    })
}
