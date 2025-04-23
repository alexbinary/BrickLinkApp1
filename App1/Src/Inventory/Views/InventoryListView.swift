
import SwiftUI



struct InventoryListView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    @State var searchText = ""
    
 
    var body: some View {
        
        let inventories = inventoryStore.allInventories(matching: searchText)
        
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12) {
                
                ForEach(inventories) { item in
                    
                    InventoryItemView(item: item)
                        .padding(.horizontal)
                }
            }
            .searchable(text: $searchText, prompt: "Search inventories")
            .padding(.vertical)
        }
        .navigationTitle("Inventory")
        .navigationSubtitle("\(inventories.count) lots, \(inventories.reduce(0, { $0+$1.quantity })) items")
        .task { await inventoryStore.softRefreshInventories() }
    }
}



#Preview {
    
    NavigationSplitView {
        
    } detail: {
        
        InventoryListView()
    }
    .previewEnv()
}
