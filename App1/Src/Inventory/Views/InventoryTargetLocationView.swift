
import SwiftUI



struct InventoryTargetLocationView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let newLocation: Location?
    let candidateItems: [InventoryItem]
    
    let itemsLimit = 50


    var body: some View {


        VStack(alignment: .leading) {
            
            let itemsInNewLocation = inventoryStore.allInventories.filter { newLocation != nil && Location(from: $0.remarks) == newLocation }
            
            let conflictingItems: [InventoryItem] = candidateItems.flatMap { sourceItem in
                
                itemsInNewLocation
                    .filter({ $0.ref == sourceItem.ref && $0.condition != sourceItem.condition })
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
                
                InventoryLocationItemsView(items: itemsInNewLocation, itemViewBuilder: { item, view in
                    
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
            }
        }
    }
}
