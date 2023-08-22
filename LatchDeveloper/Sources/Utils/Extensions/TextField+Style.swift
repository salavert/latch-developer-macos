import SwiftUI

extension TextField {
    public func textFieldCustomStyle(backgroundColor: Color = .white, strokeColor: Color = .gray.opacity(0.7)) -> some View {
        textFieldStyle(.plain)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(backgroundColor)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
    
    public func textFieldConfigStyle() -> some View {
        textFieldStyle(.plain)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.gray.opacity(0.7), lineWidth: 1)
            )
    }
}
