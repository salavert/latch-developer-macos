import Foundation
import SwiftUI

struct OnLoadViewModifier: ViewModifier {
    let perform: () -> Void
    @State private var firstTime = true

    func body(content: Content) -> some View {
        content
            .onAppear {
                if firstTime {
                    firstTime = false
                    self.perform()
                }
            }
    }
}

public extension View {
    /// Adds an action to perform when this view appears just the first time.
    func onLoad(perform: @escaping () -> Void) -> some View {
        modifier(OnLoadViewModifier(perform: perform))
    }
}
