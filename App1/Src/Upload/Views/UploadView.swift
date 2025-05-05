
import SwiftUI



struct UploadView: View {

    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    @State var activeItemId: UploadItem.ID? = nil
    
    
    var body: some View {
        
        let items = uploadStore.uploadItemsForList
            .sorted(by: { a, b in
                return a.itemIsValid
            })
        
        VStack {
            
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
                    
                    if let id = activeItemId {
                        UploadActiveItemView(uploadItemId: id)
                            .padding()
                    }
                    
                    Section {
                        ForEach(items.filter({ $0.id != activeItemId })) { item in
                            UploadItemView(uploadItem: item)
                                .padding([.leading, .trailing])
                                .onTapGesture {
                                    activeItemId = item.id
                                }
                        }
                        Color.clear.frame(width: 0, height: 24)
                    } header: {
                        SectionHeader("􀋲 Next", secondaryText: "\(items.count) lots, \(items.reduce(0, { $0 + ($1.qty ?? 0) })) items")
                    }
                }
            }
        }
        .onChange(of: items, initial: true) {
            
            if !items.contains(where: { $0.id == activeItemId }) {
                activeItemId = items.first?.id
            }
        }
    }
}
