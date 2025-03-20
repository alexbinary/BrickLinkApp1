
import SwiftUI



struct UploadItemsView: View {
    
    
    @Environment(UploadStore.self)
    var uploadStore
    

    var body: some View {

        let items = uploadStore.uploadItemsForList
        
        LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(items) { UploadItemView(uploadItem: $0).padding([.leading, .trailing]) }
                Color.clear.frame(width: 0, height: 24)
            } header: {
                SectionHeader("􀋲 Items to upload", secondaryText: "\(items.count) items")
            }
        }
    }
}



#Preview {
    
    let env = createEnv()
    
    UploadItemsView()
        .inject(env)
}
