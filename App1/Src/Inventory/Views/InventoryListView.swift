
import SwiftUI



struct InventoryListView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    @State var searchText = ""
    @State var actionPopoverPresented: Bool = false
    
 
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
        .toolbar {
            Button {
                actionPopoverPresented.toggle()
            } label: {
                Text("􀈫").padding(.horizontal)
            }
            .popover(isPresented: $actionPopoverPresented, arrowEdge: .bottom) {
                InventoryActionSheet(items: inventories)
            }
        }
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
