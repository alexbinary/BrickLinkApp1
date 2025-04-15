
import SwiftUI



struct InfoCardView<Content, Detail>: View where Content: View, Detail: View {
    
    
    let title: String
    let content: Content
    let detail: Detail
    
    init(
        title: String,
        @ViewBuilder _ content:  () -> Content,
        @ViewBuilder detail: () -> Detail
    ) {
        self.title = title
        self.content = content()
        self.detail = detail()
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: title)
            
            VStack(alignment: .center, spacing: 12) {
                
                content
                detail
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(8)
        .roundedContainer(style: .outline)
    }
}


#Preview {
    InfoCardView(title: "Title") {
        Text("Content")
    } detail: {
        Text("detail")
    }
}
