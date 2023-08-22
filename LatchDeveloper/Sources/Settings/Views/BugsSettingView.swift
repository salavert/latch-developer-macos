import ComposableArchitecture
import SwiftUI

struct BugsSettingsView: View {
    
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<AppReducer.State, AppReducer.Action>

    init(store: StoreOf<AppReducer>) {
        self.store = store
        viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20){
            Text("If you need to file a bug please let us know")
                .font(.headline)
                .fontWeight(.regular)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 20) {
                VStack {
                    Spacer()
                    Image("face")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .clipShape(.circle)
                    Spacer()
                    Text("[Jose Salavert](mailto:jose.salavert.moreno@telefonica.com)")
                        .font(.headline)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.center)
                }
                Divider()
                VStack {
                    Spacer()
                    Image("big-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 45)
                        .tint(.latch)
                    Spacer()
                    Text("[Latch Team channel](https://teams.microsoft.com/l/channel/19%3a8aZZYsMk188i-IFJ2scbqC9CIIPoGuSx1alHuR_1bQU1%40thread.tacv2/General?groupId=e82a7741-8aad-483c-b287-a2c96deda85b&tenantId=9744600e-3e04-492e-baa1-25ec245c6f10)")
                        .font(.headline)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                }
                Divider()
                VStack {
                    Spacer()
                    Image(systemName: "apple.logo")
                        .font(.system(size: 40))
                    Spacer()
                    Text("[Apps Team channel](https://teams.microsoft.com/l/channel/19%3a5e98d1145be74c9290e67741e01c0100%40thread.skype/Apps%2520Team?groupId=bef9be07-03e4-4afb-8a79-f720a63e4c28&tenantId=9744600e-3e04-492e-baa1-25ec245c6f10)")
                        .font(.headline)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.center)
                }
            }   
            
            Spacer()
        }
        .padding(20)
        .frame(width: 460, height: 170)
    }
}

#Preview {
    BugsSettingsView(store: .init(initialState: AppReducer.State()) {
        AppReducer()
    })
}
