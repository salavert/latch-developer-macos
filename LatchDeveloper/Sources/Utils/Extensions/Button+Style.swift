import SwiftUI

extension Button {
    public func buttonCustomStle() -> some View {
        buttonStyle(.plain)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color("latch"))
            .cornerRadius(2)
    }
}
