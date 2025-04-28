
import SwiftUI



struct UploadAddView: View {
    
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!


    var body: some View {

        VStack {
            
            UploadAddFormView()
                .padding()
            
            ScrollView {
                
                let items = uploadStore.uploadItemsForList
                
                LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                    Section {
                        ForEach(items) {
                            UploadAddItemView(uploadItem: $0)
                                .padding([.leading, .trailing])
                        }
                        Color.clear.frame(width: 0, height: 24)
                    } header: {
                        SectionHeader("􀋲 Items to upload", secondaryText: "\(items.count) items")
                    }
                }
            }
        }
    }
}
