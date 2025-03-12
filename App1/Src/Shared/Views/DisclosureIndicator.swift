
import SwiftUI



struct DisclosureIndicator: View {

    var body: some View {
        
        Image(systemName: "chevron.right")
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(.tertiary)
    }
}



#Preview {
    DisclosureIndicator()
}
