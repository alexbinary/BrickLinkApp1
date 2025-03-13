
import SwiftUI



struct SectionHeader: View {
    
    
    let primaryText: String
    let secondaryText: String
    
    init(_ primaryText: String, secondaryText: String = "") {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
    }

    
    var body: some View {

        HStack(spacing: 24) {
            Text(primaryText).font(.title3)
            Text(secondaryText).foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .background(Color.windowBackgroundColor.opacity(0.90))
    }
}



#Preview {
    SectionHeader("Title")
}
