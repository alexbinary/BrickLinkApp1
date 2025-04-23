
import SwiftUI



struct InventoryActionSheet: View {

    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let items: [InventoryItem]
    
    
    @State var editLocation: String = ""
    
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            
            Text("Move \(items.count) items to")
            
            TextField("New location", text: $editLocation)
            
            HStack {
                
                Button("Move") {
                    if let loc = validatedLocation.valueToSubmit {
                        self.moveItems(to: loc)
                    }
                }
                .disabled(validatedLocation.hasWarning)
                
                if validatedLocation.hasWarning {
                    Text("invalid location").foregroundStyle(.red)
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
    InventoryActionSheet(items: [])
}
