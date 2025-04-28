
import SwiftUI



struct UploadHistoryView: View {
    
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    
    @State var searchText = ""
    
    
    var body: some View {
     
        ScrollView {
            
            let items = uploadStore.uploadedItemsForList(matching: searchText)
            
            LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                ForEach(items.grouppedByDay, id: \.day) { (day, items) in
                    Section {
                        ForEach(items) {
                            UploadHistoryItemView(uploadedItem: $0)
                                .padding([.leading, .trailing])
                        }
                        Color.clear.frame(width: 0, height: 24)
                    } header: {
                        SectionHeader("􀐫 \(day)", secondaryText: "\(items.count) items")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search items")
        }
    }
}



#Preview {
    
    let env = createEnv()
    
    UploadHistoryView()
        .inject(env)
}
