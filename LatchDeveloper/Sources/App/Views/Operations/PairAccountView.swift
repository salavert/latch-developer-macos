import ComposableArchitecture
import SwiftUI

struct PairAccountView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>
    @State var activeSubMenu: PairAccountSubMenu = .pairWithToken

    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        Picker(selection: $activeSubMenu) {
            ForEach(PairAccountSubMenu.allCases, id: \.self) { menu in
                Text(menu.rawValue)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        
        switch activeSubMenu {
        case .pairWithId:
            IfLetStore(
                store.scope(state: \.pairAccountWithId, action: AppReducer.Action.pairAccountWithId),
                then: PairAccountWithIdView.init
            )
        case .pairWithToken:
            IfLetStore(
                store.scope(state: \.pairAccountWithToken, action: AppReducer.Action.pairAccountWithToken),
                then: PairAccountWithTokenView.init
            )
        }
    }
}

#Preview {
    OperationsView(store: .init(initialState: AppReducer.State()) {
        AppReducer()
    })
}
