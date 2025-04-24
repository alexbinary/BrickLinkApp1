
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
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
                
                ForEach(items.limit(itemsLimit)) { item in
                    view(for: item)
                }
                
                if items.count > itemsLimit {
                    Text("\(items.count-itemsLimit) more")
                }
            }
            
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
            
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
                    
                    ForEach(itemsInNewLocation.limit(itemsLimit)) { item in
                        view(for: item)
                    }
                    
                    if itemsInNewLocation.count > itemsLimit {
                        Text("\(itemsInNewLocation.count-itemsLimit) more")
                    }
                }
            }
        }
        .padding()
        .padding(.vertical)
        .onAppear {
            editLocation = defaultLocation?.description ?? ""
        }
        .frame(minWidth: 400)
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
