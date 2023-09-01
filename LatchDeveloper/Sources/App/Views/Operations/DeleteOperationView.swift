import AppCenterAnalytics
import ComposableArchitecture
import LatchSharedModels
import SwiftUI

public struct DeleteOperationReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    public struct State: Equatable {
        var operations: Operations
        var isDeletingOperation: Bool
        var isPickerDisabled: Bool
        
        @BindingState var selectedOperationId = ""
        @BindingState var manualOperationId = ""
        
        init(
            operations: Operations = [:],
            isDeletingOperation: Bool = false,
            isPickerDisabled: Bool = false
        ) {
            self.operations = operations
            self.isDeletingOperation = isDeletingOperation
            self.isPickerDisabled = isPickerDisabled
        }

        var isSubmitButtonDisabled: Bool {
            operationId.isEmpty
        }
        
        var operationId: String {
            if !selectedOperationId.isEmpty {
                return selectedOperationId
            } else if !manualOperationId.isEmpty {
                return manualOperationId
            } else {
                return ""
            }
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case deleteOperation
        case deleteOperationId(String)
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
                state.operations = repositoryClient.getOperations()
                return .none
            
            case .deleteOperation:
                Analytics.trackEvent(Events.deleteOperation)
                state.isDeletingOperation = true
                return .run { [operationId = state.operationId] send in
                    let latchResponse = try await networkClient.deleteOperation(operationId)
                    await send(.delegate(.saveResponseLog(latchResponse)))
                    let deleteOperationResponse = try? latchResponse.decodeAs(DeleteOperationResponse.self)
                    if let error = deleteOperationResponse?.error, error.code == 301 {
                        await send(.deleteOperationId(operationId))
                    } else {
                        await send(.deleteOperationId(operationId))
                    }
                }
                
            case .delegate(.saveResponseLog):
                state.isDeletingOperation = false
                return .none
                
            case .binding(\.$manualOperationId):
                if !state.manualOperationId.isEmpty {
                    state.selectedOperationId = ""
                    state.isPickerDisabled = true
                } else {
                    state.isPickerDisabled = false
                }
                return .none
                
            case let .deleteOperationId(operationId):
                var operations = repositoryClient.getOperations()
                operations.removeValue(forKey: operationId)
                repositoryClient.setOperations(operations)
                dump(repositoryClient.getOperations())
                state.operations = operations
                state.selectedOperationId = ""
                state.manualOperationId = ""
                return .none
                
            case .delegate:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct DeleteOperationView: View {
    let store: StoreOf<DeleteOperationReducer>
    @ObservedObject var viewStore: ViewStore<DeleteOperationReducer.State, DeleteOperationReducer.Action>

    init(store: StoreOf<DeleteOperationReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Delete an operation")
                .titleStyle()
            
            if !viewStore.operations.isEmpty {
                Text("Select one of the following Operation Ids:")
                    .headlineStyle()
                
                Picker(selection: viewStore.$selectedOperationId) {
                    ForEach(viewStore.operations.reversed(), id: \.key) {
                        Text("\($0.value) [*\($0.key)*]").truncationMode(.middle)
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
                Text("Specify the Operation Id to delete:")
                    .headlineStyle()
            }
            
            TextField("Operation Id", text: viewStore.$manualOperationId)
                .textFieldCustomStyle()

            Button(action: { viewStore.send(.deleteOperation) }, label: {
                HStack {
                    Spacer()
                    if viewStore.isDeletingOperation {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Delete operation")
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
    DeleteOperationView(store: .init(initialState: DeleteOperationReducer.State()) {
        DeleteOperationReducer()
    })
}
