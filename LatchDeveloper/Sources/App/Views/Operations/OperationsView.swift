import ComposableArchitecture
import SwiftUI

struct OperationsView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>
    @State var activeSubMenu: OperationSubMenu = .addOperation

    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        Picker(selection: $activeSubMenu) {
            ForEach(OperationSubMenu.allCases, id: \.self) { menu in
                Image(systemName: menu.icon)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        
        switch activeSubMenu {
        case .addOperation:
           IfLetStore(
               store.scope(state: \.addOperation, action: AppReducer.Action.addOperation),
               then: AddOperationView.init
           )
        case .deleteOperation:
           IfLetStore(
               store.scope(state: \.deleteOperation, action: AppReducer.Action.deleteOperation),
               then: DeleteOperationView.init
           )
        }
    }
}

#Preview {
    OperationsView(store: .init(initialState: AppReducer.State()) {
        AppReducer()
    })
}
