import AppKit
import ComposableArchitecture
import LatchSharedModels
import SwiftUI

struct AppReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    public struct State: Equatable {
        var pairAccountWithId: PairAccountWithIdReducer.State?
        var pairAccountWithToken: PairAccountWithTokenReducer.State?
        var unpairAccount: UnpairAccountReducer.State?
        var checkStatus: CheckStatusReducer.State?
        var modifyStatus: ModifyStatusReducer.State?
        var addOperation: AddOperationReducer.State?
        var deleteOperation: DeleteOperationReducer.State?
        var applications: ApplicationsReducer.State?
        var subscription: SubscriptionReducer.State?
        var userHistory: UserHistoryReducer.State?
        var step: Step
        var responseLogs: [ResponseLog]
        var presentedResponseLog: ResponseLog?
        var currentHistory: [GetUserHistoryResponse.History]
        var currentClientVersions: [GetUserHistoryResponse.ClientVersion]
        
        @BindingState var selectedMenuOption: MenuOption
        @BindingState var selectedResponseLogTab: LogTab
        @BindingState var selectedSettingsTab: SettingsTab
        
        public init(
            pairAccountWithId: PairAccountWithIdReducer.State? = .init(),
            pairAccountWithToken: PairAccountWithTokenReducer.State? = .init(),
            unpairAccount: UnpairAccountReducer.State? = .init(),
            checkStatus: CheckStatusReducer.State? = .init(),
            modifyStatus: ModifyStatusReducer.State? = .init(),
            addOperation: AddOperationReducer.State? = .init(),
            deleteOperation: DeleteOperationReducer.State? = .init(),
            applications: ApplicationsReducer.State? = .init(),
            subscription: SubscriptionReducer.State? = .init(),
            userHistory: UserHistoryReducer.State? = .init(),
            step: Step = .onboarding,
            selectedMenuOption: MenuOption = ApplicationConstants.defaultMenuOption,
            responseLogs: [ResponseLog] = [],
            selectedResponseLogTab: LogTab = .response,
            presentedResponseLog: ResponseLog? = nil,
            currentHistory: [GetUserHistoryResponse.History] = [],
            currentClientVersions: [GetUserHistoryResponse.ClientVersion] = [],
            selectedSettingsTab: SettingsTab = .general
        ) {
            self.pairAccountWithId = pairAccountWithId
            self.pairAccountWithToken = pairAccountWithToken
            self.unpairAccount = unpairAccount
            self.checkStatus = checkStatus
            self.modifyStatus = modifyStatus
            self.addOperation = addOperation
            self.deleteOperation = deleteOperation
            self.applications = applications
            self.subscription = subscription
            self.userHistory = userHistory
            self.step = step
            self.selectedMenuOption = selectedMenuOption
            self.responseLogs = responseLogs
            self.presentedResponseLog = presentedResponseLog
            self.selectedResponseLogTab = selectedResponseLogTab
            self.currentHistory = currentHistory
            self.currentClientVersions = currentClientVersions
            self.selectedSettingsTab = selectedSettingsTab
        }
        
        var isCopyToClipboardDisabled: Bool {
            responseLogs.isEmpty
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case addOperation(AddOperationReducer.Action)
        case applications(ApplicationsReducer.Action)
        case binding(BindingAction<State>)
        case checkStatus(CheckStatusReducer.Action)
        case copyToClipboardPresentedLog
        case configure(ApplicationConfig)
        case deleteOperation(DeleteOperationReducer.Action)
        case didFinishLaunching
        case generalSettingsChanged
        case modifyStatus(ModifyStatusReducer.Action)
        case presentBugs
        case presentConfiguration
        case pairAccountWithId(PairAccountWithIdReducer.Action)
        case pairAccountWithToken(PairAccountWithTokenReducer.Action)
        case presentResponseLog(ResponseLog)
        case saveOperations([String: GetApplicationsResponse.Operation]?)
        case saveResponseLog(LatchResponse)
        case subscription(SubscriptionReducer.Action)
        case unpairAccount(UnpairAccountReducer.Action)
        case userHistory(UserHistoryReducer.Action)
    }
    
    public enum Step: Equatable {
        case onboarding
        case home(ApplicationConfig)
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        self.core
            .ifLet(\.pairAccountWithId, action: /Action.pairAccountWithId) {
                PairAccountWithIdReducer()
            }
            .ifLet(\.pairAccountWithToken, action: /Action.pairAccountWithToken) {
                PairAccountWithTokenReducer()
            }
            .ifLet(\.unpairAccount, action: /Action.unpairAccount) {
                UnpairAccountReducer()
            }
            .ifLet(\.checkStatus, action: /Action.checkStatus) {
                CheckStatusReducer()
            }
            .ifLet(\.modifyStatus, action: /Action.modifyStatus) {
                ModifyStatusReducer()
            }
            .ifLet(\.addOperation, action: /Action.addOperation) {
                AddOperationReducer()
            }
            .ifLet(\.deleteOperation, action: /Action.deleteOperation) {
                DeleteOperationReducer()
            }
            .ifLet(\.applications, action: /Action.applications) {
                ApplicationsReducer()
            }
            .ifLet(\.subscription, action: /Action.subscription) {
                SubscriptionReducer()
            }
            .ifLet(\.userHistory, action: /Action.userHistory) {
                UserHistoryReducer()
            }
    }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .didFinishLaunching,
                    .generalSettingsChanged:
                if let applicationConfig = repositoryClient.getApplicationConfig(), applicationConfig.isValid {
                    Log.debug(.app, applicationConfig.description)
                    return configure(applicationConfig, state: &state)
                } else {
                    state.step = .onboarding
                    return .none
                }
                
            case let .configure(applicationConfig),
                let .applications(.delegate(.configure(applicationConfig))):
                if applicationConfig.isValid {
                    return configure(applicationConfig, state: &state)
                } else {
                    state.step = .onboarding
                    return .none
                }
                
            case .presentBugs:
                state.selectedSettingsTab = .bugs
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                return .none
                
            case .presentConfiguration:
                state.selectedSettingsTab = .general
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                return .none
                
            case let .saveResponseLog(latchResponse),
                let .pairAccountWithId(.delegate(.saveResponseLog(latchResponse))),
                let .pairAccountWithToken(.delegate(.saveResponseLog(latchResponse))),
                let .unpairAccount(.delegate(.saveResponseLog(latchResponse))),
                let .checkStatus(.delegate(.saveResponseLog(latchResponse))),
                let .modifyStatus(.delegate(.saveResponseLog(latchResponse))),
                let .addOperation(.delegate(.saveResponseLog(latchResponse))),
                let .deleteOperation(.delegate(.saveResponseLog(latchResponse))),
                let .applications(.delegate(.saveResponseLog(latchResponse))),
                let .subscription(.delegate(.saveResponseLog(latchResponse))),
                let .userHistory(.delegate(.saveResponseLog(latchResponse))):
                let log = ResponseLog(
                    date: Date(),
                    response: latchResponse
                )
                state.responseLogs.append(log)
                state.presentedResponseLog = log
                return .none
                
            case let .presentResponseLog(responseLog):
                state.presentedResponseLog = responseLog
                return .none
                
            case .copyToClipboardPresentedLog:
                if let log = state.presentedResponseLog {
                    NSPasteboard.general.clearContents()
                    switch state.selectedResponseLogTab {
                    case .request:
                        NSPasteboard.general.setString(log.requestDescription, forType: .string)
                    case .response:
                        NSPasteboard.general.setString(log.responseDescription, forType: .string)
                    }
                }
                return .none
              
            case let .saveOperations(operations):
                saveAllOperationsOfCurrentApp(operations, state: &state)
                return .none
                
            case .binding:
                return .none
                
            case .pairAccountWithId:
                return .none
                
            case .pairAccountWithToken:
                return .none
                
            case .checkStatus:
                return .none
                
            case .unpairAccount:
                return .none
            
            case .modifyStatus:
                return .none
                
            case .addOperation:
                return .none
                
            case .deleteOperation:
                return .none
            
            case .applications:
                return .none
                
            case .subscription:
                return .none
            
            case .userHistory:
                return .none
            }
        }
    }
}

private extension AppReducer {
    func configure(_ applicationConfig: ApplicationConfig, state: inout State) -> Effect<Action> {
        if applicationConfig.appId != repositoryClient.getCurrentApplicationId() {
            Log.debug(.app, "Deleting all stored data related to current account before switching to appId \(applicationConfig.appId)")
            repositoryClient.clearCurrentApplicationRelatedData()
        }
        repositoryClient.setApplicationConfig(applicationConfig)
        state.step = .home(applicationConfig)
        if state.selectedMenuOption.disabled {
            state.selectedMenuOption = ApplicationConstants.defaultMenuOption
        }
        return .run { send in
            let latchResponse = try await networkClient.applications()
            if let applicationsResponse = try? latchResponse.decodeAs(GetApplicationsResponse.self) {
                await send(.saveOperations(applicationsResponse.data?.operations))
            }
        }
    }
    
    func saveAllOperationsOfCurrentApp(_ operations: [String: GetApplicationsResponse.Operation]?, state: inout State) {
        let applicationConfig = repositoryClient.getApplicationConfig()
        let currentApplication = operations?.filter({ $0.key == applicationConfig?.appId }).first
        
        var operationsKeys: Operations = [:]
        if let currentApplication {
            operationsKeys.updateValue(currentApplication.value.name, forKey: currentApplication.key)
        }
        if let operations = currentApplication?.value.operations {
            getAllOperationKeys(operations)
                .filter({ operationsKeys.index(forKey: $0.key) == nil })
                .forEach { operationsKeys.updateValue($0.value, forKey: $0.key) }
        }
        repositoryClient.setOperations(operationsKeys)
        dump(operationsKeys)
    }
    
    func getAllOperationKeys(_ operations: [String: GetApplicationsResponse.Operation]) -> [String : String] {
        var keys: Operations = [:]
        operations.forEach {
            keys.updateValue($0.value.name, forKey: $0.key)
            if let childOperations = $0.value.operations, !childOperations.isEmpty {
                getAllOperationKeys(childOperations)
                    .filter({ keys.index(forKey: $0.key) == nil })
                    .forEach { keys.updateValue($0.value, forKey: $0.key) }
            }
        }
        return keys
    }
}

struct AppView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<ViewState, AppReducer.Action>
    
    @State private var blobMove = false
    @State var detailPresented = false
    
    struct ViewState: Equatable {
        let showOnboarding: Bool
        
        init(state: AppReducer.State) {
            self.showOnboarding = state.step == .onboarding
        }
    }
    
    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }

    var body: some View {
        VStack {
            if viewStore.showOnboarding {
                OnboardingView(store: store)
                    .background(
                        blobBackground
                    )
            } else {
                HomeView(store: store)
            }
        }
        .frame(width: 1000, height: 550, alignment: .center)
        .preferredColorScheme(.light)
    }
    
    var blobBackground: some View {
        ZStack {
            Image("Blob-1-blur")
                .rotationEffect(.degrees(90))
                .offset(x: blobMove ? 200 : 220, y: blobMove ? 100 : -80)
                .animation(.linear(duration: 10).repeatForever(autoreverses: true), value: blobMove)
            Image("Blob-2-blur")
                .rotationEffect(.degrees(-280))
                .offset(x: blobMove ? 170 : 200, y: blobMove ? -30 : 40)
                .animation(.linear(duration: 15).repeatForever(autoreverses: true), value: blobMove)
                .task {
                    blobMove.toggle()
                }
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppReducer.State()) {
        AppReducer()
    })
}
