import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {
    var screen = NSScreen.main?.visibleFrame
    
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>

    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack(spacing: 0){
            Spacer(minLength: 50)
        
            VStack(alignment: .center, spacing: 15){
                Spacer()
                
                Text("Latch Developer _for_ macOS")
                    .largeTitleStyle()
                
                Text("This application is provided for exclusive usage of Telefonica S.A. employees for testing purposes of [Latch API](https://latch.telefonica.com/www/developers/doc_api).")
                    .headlineStyle()
                    .tint(.indigo)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                    
                Button(action: { viewStore.send(.presentConfiguration) }, label: {
                    HStack {
                        Spacer()
                        Text("Configure now")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .contentShape(Rectangle())
                })
                .buttonCustomStle()
                .frame(maxWidth: 200)

                Link("Latch Developer area", destination: URL(string: "\(ApplicationConstants.defaultHost)/www/developers/editapplication")!)
                    
                Spacer()
            }

            Spacer(minLength: 50)

            Image("logo-box")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 350)
            
            Spacer()
        }
        .padding(.horizontal, 50)
    }
}

#Preview {
    OnboardingView(store: Store(initialState: AppReducer.State()) {
        AppReducer()
    })
}
