import AppCenterAnalytics
import ComposableArchitecture
import LatchSharedModels
import SwiftUI

public struct AddOperationReducer: Reducer {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    public struct State: Equatable {
        var operations: Operations
        var isAddingOperation: Bool
        var isPickerDisabled: Bool
        
        @BindingState var selectedParentId = ""
        @BindingState var manualParentId = ""
        @BindingState var name = ""
        @BindingState var twoFactor: OptionalFeature = .disabled
        @BindingState var lockOnRequest: OptionalFeature = .disabled
        
        init(
            operations: Operations = [:],
            isAddingOperation: Bool = false,
            isPickerDisabled: Bool = false
        ) {
            self.operations = operations
            self.isAddingOperation = isAddingOperation
            self.isPickerDisabled = isPickerDisabled
        }
        
        var isSubmitButtonDisabled: Bool {
            name.isEmpty || parentId.isEmpty
        }
        
        var parentId: String {
            if !selectedParentId.isEmpty {
                return selectedParentId
            } else if !manualParentId.isEmpty {
                return manualParentId
            } else {
                return ""
            }
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case addOperation
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case onLoad
        case saveOperation(String, String)
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
            
            case .addOperation:
                Analytics.trackEvent(Events.addOperation)
                state.isAddingOperation = true
                return .run { [
                    parentId = state.parentId,
                    name = state.name,
                    twoFactor = state.twoFactor,
                    lockOnRequest = state.lockOnRequest
                ] send in
                    let latchResponse = try await networkClient.addOperation(
                        parentId,
                        name,
                        twoFactor,
                        lockOnRequest
                    )
                    await send(.delegate(.saveResponseLog(latchResponse)))
                    let addOperationResponse = try? latchResponse.decodeAs(AddOperationResponse.self)
                    if addOperationResponse?.error == nil, let operationId = addOperationResponse?.data?.operationId {
                        await send(.saveOperation(operationId, name))
                    }
                }
                
            case .delegate(.saveResponseLog):
                state.isAddingOperation = false
                return .none
                
            case .binding(\.$manualParentId):
                if !state.manualParentId.isEmpty {
                    state.selectedParentId = ""
                    state.isPickerDisabled = true
                } else {
                    state.isPickerDisabled = false
                }
                return .none
                
            case let .saveOperation(id, name):
                var operations = repositoryClient.getOperations()
                operations.updateValue(name, forKey: id)
                repositoryClient.setOperations(operations)
                dump(repositoryClient.getOperations())
                state.operations = operations
                state.name = ""
                state.selectedParentId = ""
                state.manualParentId = ""
                state.twoFactor = .disabled
                state.lockOnRequest = .disabled
                return .none
            
            case .delegate:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct AddOperationView: View {
    let store: StoreOf<AddOperationReducer>
    @ObservedObject var viewStore: ViewStore<AddOperationReducer.State, AddOperationReducer.Action>

    init(store: StoreOf<AddOperationReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add a sub operation")
                .titleStyle()
            
            TextField("Operation name", text: viewStore.$name)
                .textFieldCustomStyle()

            if !viewStore.operations.isEmpty {
                Text("Select the parent Operation Id:")
                    .headlineStyle()

                if viewStore.operations.count > 6 {
                    operationsPicker
                        .pickerStyle(.menu)
                } else {
                    operationsPicker
                        .pickerStyle(.inline)
                }
                
                Text("Or specify it manually:")
                    .headlineStyle()
            } else {
                Text("Specify the parent Operation Id:")
                    .headlineStyle()
            }
            
            TextField("Operation Id", text: viewStore.$manualParentId)
                .textFieldCustomStyle()
            
            Text("Second factor authentication:")
                .headlineStyle()

            Picker(selection: viewStore.$twoFactor) {
                ForEach(OptionalFeature.allCases, id: \.self) {
                    switch $0 {
                    case .disabled:
                        Text("Disabled")
                    case .mandatory:
                        Text("Mandatory")
                    case .optional:
                        Text("Optional")
                    }
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            
            Text("Lock on request:")
                .headlineStyle()

            Picker(selection: viewStore.$lockOnRequest) {
                ForEach(OptionalFeature.allCases, id: \.self) {
                    switch $0 {
                    case .disabled:
                        Text("Disabled")
                    case .mandatory:
                        Text("Mandatory")
                    case .optional:
                        Text("Optional")
                    }
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            
            Button(action: { viewStore.send(.addOperation) }, label: {
                HStack {
                    Spacer()
                    if viewStore.isAddingOperation {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Add operation")
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

private extension AddOperationView {
    var operationsPicker: some View {
        Picker(selection: viewStore.$selectedParentId) {
            ForEach(viewStore.operations.reversed(), id: \.key) {
                Text("\($0.value) [*\($0.key)*]").truncationMode(.middle)
                    .lineLimit(1)
            }
        } label: {
            EmptyView()
        }
        .disabled(viewStore.isPickerDisabled)
    }
}

#Preview {
    AddOperationView(store: .init(initialState: AddOperationReducer.State()) {
        AddOperationReducer()
    })
}
