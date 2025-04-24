
import SwiftUI



struct InventoryActionSheet: View {

    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let items: [InventoryItem]
    
    
    @State var editLocation: String = ""
    
    @Binding var recentMoveLocations: [Location]
    @Binding var recentActions: [InventoryAction]
    
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            
            Text("Move \(items.count) items to")
            
            TextField("New location", text: $editLocation)
            
            if !recentMoveLocations.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("recent:")
                    HStack {
                        ForEach(recentMoveLocations, id: \.description) { loc in
                            Button(loc.description) {
                                editLocation = loc.description
                            }
                        }
                    }
                }
            }
            
            HStack {
                
                Button("Move") {
                    if let loc = validatedLocation.valueToSubmit {
                        self.moveItems(to: loc)
                        self.addRecentLocation(loc)
                        self.addRecentMoveAction(to: loc)
                    }
                }
                .disabled(validatedLocation.valueToSubmit == nil)
                
                if validatedLocation.hasWarning {
                    Text("invalid").foregroundStyle(.red)
                }
                
                if isUpdatingItems {
                    ProgressView().controlSize(.small)
                }
            }
        }
        .padding()
    }
    
    
    var validatedLocation: ValidatedValue<Location> {
        
        if let loc = Location(from: editLocation) {
            .init(valueToSubmit: loc, hasWarning: false)
        } else if editLocation.isEmpty {
            .init(valueToSubmit: nil, hasWarning: false)
        } else {
            .init(valueToSubmit: nil, hasWarning: true)
        }
    }
    
    
    func moveItems(to loc: Location) {
        
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
    
    
    func addRecentLocation(_ loc: Location) {
        
        var recent = recentMoveLocations
        recent.insert(loc, at: 0)
        recentMoveLocations = recent.unique.limit(3)
    }
    
    
    func addRecentMoveAction(to loc: Location) {
        
        var recent = recentActions
        recent.insert(.move(to: loc), at: 0)
        recentActions = recent.unique.limit(3)
    }
    
    
    var isUpdatingItems: Bool {
    
        for item in items {
            if inventoryStore.isUpdatingInventory(withId: item.id) {
                return true
            }
        }
        return false
    }
}



#Preview {
    InventoryActionSheet(
        items: [],
        recentMoveLocations: .constant([]),
        recentActions: .constant([])
    )
}
