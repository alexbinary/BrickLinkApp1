
import SwiftUI



struct UploadedItemsView: View {
    
    
    @Environment(UploadStore.self)
    var uploadStore
    
    
    @State var searchText = ""
    
    
    var body: some View {
     
        let items = uploadStore.uploadedItemsForList(matching: searchText)
        
        LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
            ForEach(items.grouppedByDay, id: \.day) { (day, items) in
                Section {
                    ForEach(items) { UploadedItemView(uploadedItem: $0).padding([.leading, .trailing]) }
                    Color.clear.frame(width: 0, height: 24)
                } header: {
                    SectionHeader("􀐫 \(day)", secondaryText: "\(items.count) items")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search items")
    }
}



#Preview {
    
    let stores = createStores()
    let uploadStore = stores.upload
    
    UploadedItemsView()
        .environment(uploadStore)
}
