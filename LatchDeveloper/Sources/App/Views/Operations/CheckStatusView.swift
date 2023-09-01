import ComposableArchitecture
import LatchSharedModels
import SwiftUI

public struct CheckStatusReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    public struct State: Equatable {
        var pairedAccounts: [String]
        var isCheckingStatus: Bool
        var isPickerDisabled: Bool
        
        @BindingState var selectedAccountId = ""
        @BindingState var manualAccountId = ""
        @BindingState var operationId = ""
        @BindingState var silent = false
        @BindingState var noOTP = false
        
        init(
            pairedAccounts: [String] = [],
            isCheckingStatus: Bool = false,
            isPickerDisabled: Bool = false
        ) {
            self.pairedAccounts = pairedAccounts
            self.isCheckingStatus = isCheckingStatus
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
        case checkStatus
        case saveOperations([String])
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
                
            case .checkStatus:
                state.isCheckingStatus = true
                var accountId: String
                if !state.selectedAccountId.isEmpty {
                    accountId = state.selectedAccountId
                } else {
                    accountId = state.manualAccountId
                }
                return .run { [
                    accountId = accountId,
                    operationId = state.operationId,
                    silent = state.silent,
                    noOTP = state.noOTP
                ] send in
                    let latchResponse = try await networkClient.operationStatus(
                        accountId,
                        operationId,
                        silent,
                        noOTP
                    )
                    await send(.delegate(.saveResponseLog(latchResponse)))
                    let checkStatusResponse = try? latchResponse.decodeAs(CheckStatusResponse.self)
                    dump(checkStatusResponse)
                    if checkStatusResponse?.error == nil, let operations = checkStatusResponse?.data?.operations {
                        await send(.saveOperations(operations.keys.sorted()))
                    }
                }
                
            case .delegate(.saveResponseLog):
                state.isCheckingStatus = false
                return .none
                
            case .binding(\.$manualAccountId):
                if !state.manualAccountId.isEmpty {
                    state.selectedAccountId = ""
                    state.isPickerDisabled = true
                } else {
                    state.isPickerDisabled = false
                }
                return .none
            
            case let .saveOperations(operations):
                var storedOperations = repositoryClient.getOperations()
                operations
                    .filter({ storedOperations.index(forKey: $0) == nil })
                    .forEach { storedOperations.updateValue($0, forKey: $0) }
                repositoryClient.setOperations(storedOperations)
                dump(repositoryClient.getOperations())
                return .none
                
            case .delegate:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct CheckStatusView: View {
    let store: StoreOf<CheckStatusReducer>
    @ObservedObject var viewStore: ViewStore<CheckStatusReducer.State, CheckStatusReducer.Action>

    init(store: StoreOf<CheckStatusReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Check account status")
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

            Toggle(isOn: viewStore.$silent) {
                Text("No enviar notificaciones push a las apps")
            }
            .toggleStyle(.switch)
            
            Toggle(isOn: viewStore.$noOTP) {
                Text("Eliminar contraseña de un solo uso en la respuesta")
            }
            .toggleStyle(.switch)
            
            Button(action: { viewStore.send(.checkStatus) }, label: {
                HStack {
                    Spacer()
                    if viewStore.isCheckingStatus {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Check status")
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

private extension CheckStatusView {
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
    CheckStatusView(store: .init(initialState: CheckStatusReducer.State()) {
        CheckStatusReducer()
    })
}
