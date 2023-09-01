import AppCenterAnalytics
import ComposableArchitecture
import LatchSharedModels
import SwiftUI

public struct ModifyStatusReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    public struct State: Equatable {
        var pairedAccounts: [String]
        var isModifyingStatus: Bool
        var isPickerDisabled: Bool
        
        @BindingState var selectedAccountId = ""
        @BindingState var manualAccountId = ""
        @BindingState var operationId = ""
        @BindingState var lock = false
        
        init(
            pairedAccounts: [String] = [],
            isModifyingStatus: Bool = false,
            isPickerDisabled: Bool = false
        ) {
            self.pairedAccounts = pairedAccounts
            self.isModifyingStatus = isModifyingStatus
            self.isPickerDisabled = isPickerDisabled
        }
        
        var isSubmitButtonDisabled: Bool {
            selectedAccountId.isEmpty && manualAccountId.isEmpty
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case modifyStatus
        case onLoad
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
                
            case .modifyStatus:
                Analytics.trackEvent(Events.modifyStatus)
                state.isModifyingStatus = true
                var accountId: String
                if !state.selectedAccountId.isEmpty {
                    accountId = state.selectedAccountId
                } else {
                    accountId = state.manualAccountId
                }
                return .run { [
                    accountId = accountId,
                    operationId = state.operationId,
                    lock = state.lock
                ] send in
                    if lock {
                        let latchResponse = try await networkClient.lock(
                            accountId,
                            operationId
                        )
                        await send(.delegate(.saveResponseLog(latchResponse)))
                    } else {
                        let latchResponse = try await networkClient.unlock(
                            accountId,
                            operationId
                        )
                        await send(.delegate(.saveResponseLog(latchResponse)))
                    }
                }
                
            case .delegate(.saveResponseLog):
                state.isModifyingStatus = false
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

struct ModifyStatusView: View {
    let store: StoreOf<ModifyStatusReducer>
    @ObservedObject var viewStore: ViewStore<ModifyStatusReducer.State, ModifyStatusReducer.Action>

    init(store: StoreOf<ModifyStatusReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Modify account status")
                .titleStyle()
            
            if !viewStore.pairedAccounts.isEmpty {
                Text("Select one of the following paired Account Ids:")
                    .headlineStyle()
                
                if viewStore.pairedAccounts.count > 6 {
                    accountsPicker
                        .pickerStyle(.menu)
                } else {
                    accountsPicker
                        .pickerStyle(.inline)
                }
                
                Text("Or specify one manually:")
                    .headlineStyle()
            } else {
                Text("Specify the Account Id to check status:")
                    .headlineStyle()
            }
            
            TextField("Account Id", text: viewStore.$manualAccountId)
                .textFieldCustomStyle()

            Text("If you have created one or more operations to be controlled by individual Latches, you can query the status of each operation using its operation identifier:")
                .headlineStyle()
            
            TextField("Operation Id (Optional)", text: viewStore.$operationId)
                .textFieldCustomStyle()
            
            Toggle(isOn: viewStore.$lock) {
                Text("Lock")
            }
            .toggleStyle(.switch)
            
            Button(action: { viewStore.send(.modifyStatus) }, label: {
                HStack {
                    Spacer()
                    if viewStore.isModifyingStatus {
                        ProgressView()
                            .controlSize(.small)
                    } else if viewStore.lock {
                        Image(systemName: "lock")
                        Text("Lock")
                    } else {
                        Image(systemName: "lock.open")
                        Text("Unlock")
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

private extension ModifyStatusView {
    var accountsPicker: some View {
        Picker(selection: viewStore.$selectedAccountId) {
            ForEach(viewStore.pairedAccounts.reversed(), id: \.self) {
                Text($0).truncationMode(.middle)
                    .lineLimit(1)
            }
        } label: {
            EmptyView()
        }
        .disabled(viewStore.isPickerDisabled)
    }
}
#Preview {
    ModifyStatusView(store: .init(initialState: ModifyStatusReducer.State()) {
        ModifyStatusReducer()
    })
}
