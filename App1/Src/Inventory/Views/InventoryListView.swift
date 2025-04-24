
import SwiftUI



struct InventoryListView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    @State var searchText = ""
    @State var actionPopoverPresented: Bool = false
    
    @State var recentMoveLocations: [Location] = []
    @State var recentActions: [InventoryAction] = []
    
 
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
            Menu {
                if recentActions.isEmpty {
                    Text("no recent actions")
                } else {
                    ForEach(recentActions, id: \.description) { action in
                        Button(action.description) {
                            self.run(action, on: inventories)
                        }
                    }
                }
            } label: {
                Text("􀈫").padding(.horizontal)
            } primaryAction: {
                actionPopoverPresented.toggle()
            }
            .popover(isPresented: $actionPopoverPresented, arrowEdge: .bottom) {
                InventoryActionSheet(
                    items: inventories,
                    recentMoveLocations: $recentMoveLocations,
                    recentActions: $recentActions
                )
            }
        }
        .task { await inventoryStore.softRefreshInventories() }
    }
    
    
    func run(_ action: InventoryAction, on items: [InventoryItem]) {
        
        switch action {
        case .move(let location):
            move(items, to: location)
        }
    }
    
    
    func move(_ items: [InventoryItem], to loc: Location) {
        
        for item in items {
            Task {
                await inventoryStore.updateInventory(
                    inventoryId: item.id,
                    addQuantity: 0,
                    unitPrice: nil,
                    remarks: loc.description
                )
            }
        }
    }
}



enum InventoryAction: Equatable {
    
    case move(to: Location)
    
    var description: String {
        switch self {
        case .move(let location):
            "Move items to \(location)"
        }
    }
}



#Preview {
    
    NavigationSplitView {
        
    } detail: {
        
        InventoryListView()
    }
    .previewEnv()
}
