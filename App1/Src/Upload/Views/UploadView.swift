
import SwiftUI



struct UploadView: View {

    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    @State var activeItem: UploadItem? = nil
    
    
    var body: some View {
        
        let items = uploadStore.uploadItemsForList
        
        VStack {
            
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                    
                    Section {
                    
                        if let activeItem = activeItem {
                            
                            UploadActiveItemView(uploadItem: activeItem)
                                .padding([.leading, .trailing])
                        }
                        
                        Color.clear.frame(width: 0, height: 24)
                    } header: {
                        SectionHeader("􀈧 Active item")
                    }
                    
                    Section {
                        ForEach(items.filter({ $0.id != activeItem?.id })) { item in
                            UploadItemView(uploadItem: item)
                                .padding([.leading, .trailing])
                                .onTapGesture {
                                    activeItem = item
                                }
                        }
                        Color.clear.frame(width: 0, height: 24)
                    } header: {
                        SectionHeader("􀋲 Items to upload", secondaryText: "\(items.count) items")
                    }
                }
            }
        }
        .onChange(of: items, initial: true) {
            
            if !items.contains(where: { $0.id == activeItem?.id }) {
                activeItem = items.first
            }
        }
    }
}
