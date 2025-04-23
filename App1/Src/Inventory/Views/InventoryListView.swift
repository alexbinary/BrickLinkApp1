
import SwiftUI



struct InventoryListView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
 
    var body: some View {
        
        let inventories = inventoryStore.allInventories
        
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12) {
                
                ForEach(inventories) { item in
                    
                    InventoryItemView(item: item)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Inventory")
        .navigationSubtitle("\(inventories.count) lots, \(inventories.reduce(0, { $0+$1.quantity })) items")
    }
}



#Preview {
    
    NavigationSplitView {
        
    } detail: {
        
        InventoryListView()
    }
    .previewEnv()
}
