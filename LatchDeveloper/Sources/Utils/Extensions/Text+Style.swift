import SwiftUI

extension Text {
    public func largeTitleStyle() -> some View {
        font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(.black)
    }
    
    public func titleStyle() -> some View {
        font(.title)
            .fontWeight(.medium)
            .foregroundStyle(.black)
    }
    
    public func headlineStyle() -> some View {
        font(.headline)
            .fontWeight(.light)
            .foregroundStyle(.black)
    }
    
    public func subtitleStyle() -> some View {
        font(.caption)
            .fontWeight(.light)
            .foregroundStyle(.gray)
    }
    
    public func footnoteStyle() -> some View {
        font(.footnote)
            .fontWeight(.ultraLight)
            .multilineTextAlignment(.center)
    }
    
    public func featuredStyle() -> some View {
        font(.footnote)
            .fontWeight(.regular)
            .foregroundStyle(.orange)
            .multilineTextAlignment(.center)
    }
}
