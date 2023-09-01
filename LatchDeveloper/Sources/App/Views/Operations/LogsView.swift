import AppCenterAnalytics
import ComposableArchitecture
import LatchSharedModels
import SwiftUI

struct LogsView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>
    
    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                if viewStore.responseLogs.isEmpty {
                    Text("No logs yet")
                        .headlineStyle()
                }
                
                ForEach(viewStore.responseLogs.reversed(), id: \.self) { log in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                if let statusCode = log.responseStatusCode, statusCode != 200 {
                                    Image(systemName: "xmark.circle.fill")
                                } else if log.responseBodyStatusCode != nil {
                                    Image(systemName: "checkmark.circle.badge.xmark")
                                } else {
                                    Image(systemName: "checkmark.circle")
                                }

                                Text(log.date.utc)
                                    .headlineStyle()
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            if let statusCode = log.responseBodyStatusCode ?? log.responseStatusCode,
                               let url = log.response.httpResponse?.url {
                                Text("[\(statusCode)] \(url.path())")
                                    .subtitleStyle()
                            }
                        }
                        Spacer()
                        Button(
                            action: {
                                Analytics.trackEvent(Events.showPreviousLog)
                                viewStore.send(.presentResponseLog(log))
                            },
                            label: {
                                HStack {
                                    Text("Show")
                                    Image(systemName: "arrow.right")
                                }
                                .contentShape(Rectangle())
                            }
                        )
                        .buttonCustomStle()
                    }
                }
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    LogsView(store: .init(initialState: AppReducer.State()) {
        AppReducer()
    })
}
