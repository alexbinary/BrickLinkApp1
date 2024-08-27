
import SwiftUI


struct HeaderTitleView: View {
    
    let label: String
    
    var body: some View {
        
        Text(label)
            .font(.system(size: 12).bold())
            .foregroundColor(Color(.secondaryLabelColor))
    }
}
