import AppCenterAnalytics
import ComposableArchitecture
import LatchSharedModels
import SwiftUI

public struct UserHistoryReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.repositoryClient) var repositoryClient

    public struct State: Equatable {
        var pairedAccounts: [String]
        var isGettingUserHistory: Bool
        var isPickerDisabled: Bool
        
        @BindingState var selectedAccountId = ""
        @BindingState var manualAccountId = ""
        
        init(
            pairedAccounts: [String] = [],
            isGettingApplications: Bool = false,
            isPickerDisabled: Bool = false
        ) {
            self.pairedAccounts = pairedAccounts
            self.isGettingUserHistory = isGettingApplications
            self.isPickerDisabled = isPickerDisabled
        }
        
        var isSubmitButtonDisabled: Bool {
            (selectedAccountId.isEmpty && manualAccountId.isEmpty) || isGettingUserHistory
        }
        
        var accountId: String {
            if !selectedAccountId.isEmpty {
                return selectedAccountId
            } else if !manualAccountId.isEmpty {
                return manualAccountId
            } else {
                return ""
            }
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case onLoad
        case userHistory
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
                
            case .userHistory:
                Analytics.trackEvent(Events.getUserHistory)
                state.isGettingUserHistory = true
                return .run { [accountId = state.accountId] send in
                    let latchResponse = try await networkClient.history(accountId)
                    await send(.delegate(.saveResponseLog(latchResponse)))
                    if let getUserHistoryResponse = try? latchResponse.decodeAs(GetUserHistoryResponse.self) {
                        dump(getUserHistoryResponse)
                    }
                }
                
            case .delegate(.saveResponseLog):
                state.isGettingUserHistory = false
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

struct UserHistoryView: View {
    let store: StoreOf<UserHistoryReducer>
    @ObservedObject var viewStore: ViewStore<UserHistoryReducer.State, UserHistoryReducer.Action>

    init(store: StoreOf<UserHistoryReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
            
            Button(action: { viewStore.send(.userHistory) }, label: {
                HStack {
                    Spacer()
                    if viewStore.isGettingUserHistory {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Get user history")
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

private extension UserHistoryView {
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
    ApplicationsView(store: .init(initialState: ApplicationsReducer.State()) {
        ApplicationsReducer()
    })
}
