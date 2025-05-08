
import SwiftUI



struct InventoryTargetLocationView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let newLocation: Location?
    let candidateItems: [PartDescriptor]
    let highlightItems: Set<InventoryItem.ID>
    
    let itemsLimit = 50
    let columnsCount: Int
    
    
    init(newLocation: Location?, candidateItems: [PartDescriptible], highlightItems: Set<InventoryItem.ID> = [], columnsCount: Int = 4) {
        self.newLocation = newLocation
        self.candidateItems = candidateItems.map(\.partDescriptor)
        self.highlightItems = highlightItems
        self.columnsCount = columnsCount
    }


    var body: some View {

        VStack(alignment: .leading) {
            
            let itemsInNewLocation = inventoryStore.allInventories.filter { newLocation != nil && Location(from: $0.remarks) == newLocation }
            
            let conflictingItems: [InventoryItem] = candidateItems.flatMap { sourceItem in
                
                itemsInNewLocation
                    .filter({ $0.ref == sourceItem.item_ref && $0.condition != sourceItem.item_condition })
            }
            
            if let loc = newLocation {
                
                let hasConflicts = !conflictingItems.isEmpty
                
                HStack {
                    Text("\(itemsInNewLocation.count) items in location \(loc)")
                    Spacer()
                    if hasConflicts {
                        Text("conflicts detected")
                    }
                    Text(hasConflicts ? "􀇿" : "􀆅")
                }
                .foregroundStyle(hasConflicts ? .orange : green)
            
                let itemsInNewLocation = itemsInNewLocation.sorted { item1, item2 in
                    
                    conflictingItems.contains(item1)
                }
                
                InventoryLocationItemsView(
                    items: itemsInNewLocation,
                    highlightItems: highlightItems.union(conflictingItems.map(\.id)),
                    columnsCount: columnsCount,
                    itemViewBuilder: { item, view in
                    
                    ZStack(alignment: .topLeading) {
                        
                        AnyView(view)
                        
                        if conflictingItems.contains(item) {
                            
                            Text("􀇿")
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                        }
                    }
                })
                
            } else {
                
                Text("invalid location").foregroundStyle(.red).italic()
            }
        }
    }
}
