
import SwiftUI



struct InventoryTargetLocationView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let newLocation: Location?
    let items: [InventoryItem]
    
    let itemsLimit = 50


    var body: some View {


        VStack(alignment: .leading) {
            
            let itemsInNewLocation = inventoryStore.allInventories.filter { newLocation != nil && Location(from: $0.remarks) == newLocation }
            
            let conflictingItems: [InventoryItem] = items.flatMap { sourceItem in
                
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
            
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
                    
                    let itemsInNewLocation = itemsInNewLocation.sorted { item1, item2 in
                        
                        conflictingItems.contains(item1)
                    }
                    
                    ForEach(itemsInNewLocation.limit(itemsLimit)) { item in
                        ZStack(alignment: .topLeading) {
                            view(for: item)
                            
                            if conflictingItems.contains(item) {
                                
                                Text("􀇿")
                                    .foregroundStyle(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                    
                    if itemsInNewLocation.count > itemsLimit {
                        Text("\(itemsInNewLocation.count-itemsLimit) more")
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder
    func view(for item: InventoryItem) -> some View {
        
        ZStack(alignment: .bottomTrailing) {
            CatalogImage(inventoryItem: item)
                .border(color(for: item.condition), width: 2)
            Text("x \(item.quantity)")
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                .clipShape(Capsule())
                .padding(4)
        }
        .help(catalog.colorName(forLegoColorId: item.colorId))
    }
    
    
    func color(for condition: String) -> Color {
        switch condition {
        case "U": return .red
        case "N": return .blue
        default: return .clear
        }
    }
}
