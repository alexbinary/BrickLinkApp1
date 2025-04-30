
import SwiftUI



struct InventorySwapActionSheet: View {

    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let items: [InventoryItem]
    let defaultLocation: Location?
    
    
    @State var editLocation: String = ""
    
    
    let itemsLimit = 23
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 18) {
            
            HStack {
                Text("Swap \(items.count) items").font(.title2)
                Spacer()
                Text("􀈫􁉾􀈫")
            }
            
            Text("\(items.count) items in location \(items.first?.remarks ?? "")")
            
            InventoryLocationItemsView(items: items, itemViewBuilder: { item, view in AnyView(view) })
            
            let newLocation = validatedLocation.valueToSubmit
            let itemsInNewLocation = inventoryStore.allInventories.filter { newLocation != nil && Location(from: $0.remarks) == newLocation }
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    TextField("Swap with location", text: $editLocation)
                    
                    Button("Confirm swap") {
                        if validatedLocation.valueToSubmit != nil {
                            self.swapItems(with: itemsInNewLocation)
                        }
                    }
                    .disabled(validatedLocation.valueToSubmit == nil)
                }
                
                if isUpdatingItems || validatedLocation.hasWarning {
                    
                    HStack {
                        
                        if isUpdatingItems {
                            ProgressView().controlSize(.small)
                        }
                        
                        Spacer()
                        
                        if validatedLocation.hasWarning {
                            Text("invalid location").foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            if let loc = newLocation {
                
                Text("\(itemsInNewLocation.count) items in location \(loc)")
                
                InventoryLocationItemsView(items: itemsInNewLocation, itemViewBuilder: { item, view in AnyView(view) })
            }
        }
        .padding()
        .padding(.vertical)
        .onAppear {
            editLocation = defaultLocation?.description ?? ""
        }
        .frame(minWidth: 400)
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
    
    
    func swapItems(with swapItems: [InventoryItem]) {
        
        let sourceItems = items
        let targetItems = swapItems
        
        if let remSource = sourceItems.first?.remarks, let sourceLocation = Location(from: remSource),
           let remTarget = targetItems.first?.remarks, let targetLocation = Location(from: remTarget) {
            
            for sourceItem in sourceItems {
                Task {
                    await inventoryStore.updateInventory(
                        inventoryId: sourceItem.id,
                        addQuantity: 0,
                        unitPrice: nil,
                        remarks: targetLocation.description
                    )
                }
            }
            
            for targetItem in targetItems {
                Task {
                    await inventoryStore.updateInventory(
                        inventoryId: targetItem.id,
                        addQuantity: 0,
                        unitPrice: nil,
                        remarks: sourceLocation.description
                    )
                }
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
    InventorySwapActionSheet(
        items: [],
        defaultLocation: nil
    )
}
