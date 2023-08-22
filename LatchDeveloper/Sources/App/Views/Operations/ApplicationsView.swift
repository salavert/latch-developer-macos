import ComposableArchitecture
import LatchSharedModels
import SwiftUI

public struct ApplicationsReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    public struct State: Equatable {
        var operations: [String: GetApplicationsResponse.Operation]?
        var isGettingApplications: Bool
        var appId: String
        
        init(
            operations: [String: GetApplicationsResponse.Operation]? = nil,
            isGettingApplications: Bool = false,
            appId: String = ""
        ) {
            self.operations = operations
            self.isGettingApplications = isGettingApplications
            self.appId = appId
        }
        
        var isSubmitButtonDisabled: Bool {
            isGettingApplications
        }
    }
    
    public enum Action: Equatable {
        case applications
        case configure(String, String)
        case delegate(DelegateAction)
        case onLoad
        case updateApplications(GetApplicationsResponse)
    }
    
    public enum DelegateAction: Equatable {
        case saveResponseLog(LatchResponse)
        case configure(ApplicationConfig)
    }
    
    public init() {}

    public var body: some Reducer<State, Action> {
        self.core
    }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onLoad,
                    .applications:
                state.appId = repositoryClient.getCurrentApplicationId() ?? ""
                state.isGettingApplications = true
                return .run { send in
                    let latchResponse = try await networkClient.applications()
                    await send(.delegate(.saveResponseLog(latchResponse)))
                    if let getApplicationsResponse = try? latchResponse.decodeAs(GetApplicationsResponse.self) {
                        dump(getApplicationsResponse)
                        await send(.updateApplications(getApplicationsResponse))
                    }
                }
                
            case .delegate(.saveResponseLog):
                state.isGettingApplications = false
                return .none
                
            case let .updateApplications(response):
                if let operations = response.data?.operations, !operations.isEmpty {
                    storeOperations(operations, state: &state)
                }
                return .none
                
            case let .configure(appId, appSecret):
                state.appId = appId
                let applicationConfig = repositoryClient.getApplicationConfig()
                return .send(.delegate(.configure(.init(
                    appId: appId,
                    appSecret: appSecret,
                    host: applicationConfig?.host ?? ApplicationConstants.defaultHost,
                    userId: applicationConfig?.userId,
                    userSecret: applicationConfig?.userSecret
                ))))
                
            case .delegate:
                return .none
            }
        }
    }
}

private extension ApplicationsReducer {
    func storeOperations(_ operations: [String: GetApplicationsResponse.Operation], state: inout State) {
        state.operations = [:]
        operations.forEach {
            state.operations?.updateValue($0.value, forKey: $0.key)
        }
    }
}

struct ApplicationsView: View {
    let store: StoreOf<ApplicationsReducer>
    @ObservedObject var viewStore: ViewStore<ApplicationsReducer.State, ApplicationsReducer.Action>

    init(store: StoreOf<ApplicationsReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Button(action: { viewStore.send(.applications) }, label: {
                HStack {
                    Spacer()
                    if viewStore.isGettingApplications {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Reload applications")
                    }
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                }
                .contentShape(Rectangle())
            })
            .buttonCustomStle()
            .padding(.top, 10)
            .disabled(viewStore.isSubmitButtonDisabled)

            if let operations = viewStore.operations {
                Text("Your applications:")
                    .titleStyle()
                ScrollView(showsIndicators: false) {
                    ForEach(operations.reversed(), id: \.key) { operation in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                if let imageUrl = operation.value.imageUrl, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(.rect(cornerRadius: 10))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(operation.value.name)
                                        .headlineStyle()
                                        .truncationMode(.tail)
                                    Text("**App Id:** \(operation.key)")
                                        .footnoteStyle()
                                        .truncationMode(.middle)
                                        .lineLimit(1)
                                        .textSelection(.enabled)
                                    
                                    if let secret = operation.value.secret {
                                        Text("**App Secret:** \(secret)")
                                            .footnoteStyle()
                                            .truncationMode(.middle)
                                            .lineLimit(1)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            if operation.key == viewStore.appId {
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                    Text("This is the current configured application")
                                        .headlineStyle()
                                }
                            } else if let secret = operation.value.secret {
                                Button(action: {
                                    viewStore.send(.configure(operation.key, secret))
                                }, label: {
                                    HStack {
                                        Spacer()
                                        Text("Switch to this application")
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                    }
                                    .contentShape(Rectangle())
                                })
                                .buttonCustomStle()
                                .padding(.top, 10)
                            }
                        }
                        .padding()
                        .background(operation.key == viewStore.appId ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 10))
                    }
                }
                
                Text("Application API calls are related to current app, when you have multiple applications you can switch between them here, otherwise introduce it manually at Configuration by pressing the ⛭ button.")
                    .footnoteStyle()
            }
            
            Spacer()
        }
        .onLoad { viewStore.send(.onLoad) }
        .padding()
    }
}

#Preview {
    ApplicationsView(store: .init(initialState: ApplicationsReducer.State(
        operations: [
            "any-id": .init(
                secret: "any-secret",
                contactEmail: nil,
                twoFactor: OptionalFeature.optional.rawValue,
                imageUrl: "https://latchstorage.blob.core.windows.net/pro-custom-images/nRtj8te3quNZKWeCmJZq-1692360960172.png",
                contactPhone: nil,
                lockOnRequest: OptionalFeature.mandatory.rawValue,
                name: "Fake Telefonica",
                operations: nil
            ),
            "any-other-id": .init(
                secret: "any-other-secret",
                contactEmail: nil,
                twoFactor: OptionalFeature.optional.rawValue,
                imageUrl: "https://latchstorage.blob.core.windows.net/pro-custom-images/A2ykMdFCPpVT2dDwZjMG-1692361322247.png",
                contactPhone: nil,
                lockOnRequest: OptionalFeature.mandatory.rawValue,
                name: "Fake O2",
                operations: nil
            )
        ]
    )) {
        ApplicationsReducer()
    })
}
