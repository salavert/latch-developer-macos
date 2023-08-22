import ComposableArchitecture
import SwiftUI

struct StatusView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>
    @State var activeSubMenu: StatusSubMenu = .checkStatus

    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        Picker(selection: $activeSubMenu) {
            ForEach(StatusSubMenu.allCases, id: \.self) { menu in
                Image(systemName: menu.icon)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        
        switch activeSubMenu {
        case .checkStatus:
           IfLetStore(
               store.scope(state: \.checkStatus, action: AppReducer.Action.checkStatus),
               then: CheckStatusView.init
           )
        case .modifyStatus:
           IfLetStore(
               store.scope(state: \.modifyStatus, action: AppReducer.Action.modifyStatus),
               then: ModifyStatusView.init
           )
        }
    }
}

#Preview {
    StatusView(store: .init(initialState: AppReducer.State()) {
        AppReducer()
    })
}
