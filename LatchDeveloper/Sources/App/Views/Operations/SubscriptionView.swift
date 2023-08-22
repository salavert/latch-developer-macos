import ComposableArchitecture
import LatchSharedModels
import SwiftUI

public struct SubscriptionReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    
    public struct State: Equatable {
        var isGettingSubscription: Bool
        
        init(isGettingSubscription: Bool = false) {
            self.isGettingSubscription = isGettingSubscription
        }
        
        var isSubmitButtonDisabled: Bool {
            isGettingSubscription
        }
    }
    
    public enum Action: Equatable {
        case subscription
        case delegate(DelegateAction)
    }
    
    public enum DelegateAction: Equatable {
        case saveResponseLog(LatchResponse)
    }
    
    public init() {}

    public var body: some Reducer<State, Action> {
        self.core
    }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .subscription:
                state.isGettingSubscription = true
                return .run { send in
                    let latchResponse = try await networkClient.subscription()
                    await send(.delegate(.saveResponseLog(latchResponse)))
                    let getSubscriptionResponse = try? latchResponse.decodeAs(GetSubscriptionResponse.self)
                    dump(getSubscriptionResponse)
                }
                
            case .delegate(.saveResponseLog):
                state.isGettingSubscription = false
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

struct SubscriptionView: View {
    let store: StoreOf<SubscriptionReducer>
    @ObservedObject var viewStore: ViewStore<SubscriptionReducer.State, SubscriptionReducer.Action>

    init(store: StoreOf<SubscriptionReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: { viewStore.send(.subscription) }, label: {
                HStack {
                    Spacer()
                    if viewStore.isGettingSubscription {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Get subscription")
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
    SubscriptionView(store: .init(initialState: SubscriptionReducer.State()) {
        SubscriptionReducer()
    })
}
