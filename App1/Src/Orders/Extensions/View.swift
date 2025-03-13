
import SwiftUI



extension View {
    
    
    @ViewBuilder func captionStyle() -> some View {
        
        self.font(.caption).foregroundStyle(.secondary)
    }
}
