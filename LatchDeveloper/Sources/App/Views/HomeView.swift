import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>
    
    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack(spacing: 0){
            NavigationView(store: store)
            
            VStack(alignment: .leading) {
                if let responseLog = viewStore.presentedResponseLog {
                    Picker(selection: viewStore.$selectedResponseLogTab) {
                        ForEach(LogTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue)
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.segmented)
                    ScrollView(.vertical) {
                        switch viewStore.selectedResponseLogTab {
                        case .request:
                            Text(responseLog.requestDescription)
                                .textSelection(.enabled)
                        case .response:
                            Text(responseLog.responseDescription)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.top, 15)
                    .padding(.horizontal, 15)
                } else {
                    Spacer()
                    Image(systemName: "text.word.spacing")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .foregroundStyle(.gray.opacity(0.2))
                    Spacer()
                }
            }
            .frame (width: 450)
            .foregroundColor(Color.black.opacity(0.7))
            .background(Color("json"))
        }
    }
}

#Preview {
    HomeView(store: .init(initialState: AppReducer.State()) {
        AppReducer()
    })
}
