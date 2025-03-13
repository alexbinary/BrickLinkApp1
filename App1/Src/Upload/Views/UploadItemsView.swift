
import SwiftUI



struct UploadItemsView: View {
    
    
    @EnvironmentObject
    var app: AppController
    

    var body: some View {

        let items = app.uploadItemsForList
        
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
    UploadItemsView().environmentObject(AppController())
}
