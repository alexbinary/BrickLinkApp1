
import SwiftUI



struct UploadItemsView: View {
    
    
    @Environment(UploadController.self)
    var uploadController
    

    var body: some View {

        let items = uploadController.uploadItemsForList
        
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
    
    let controllers = AppController.createControllers()
    let uploadController = controllers.uploadController
    
    UploadItemsView()
        .environment(uploadController)
}
