
import SwiftUI



struct InventoryActionSheet: View {

    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let items: [InventoryItem]
    let defaultLocation: Location?
    
    
    @State var editLocation: String = ""
    
    @Binding var recentMoveLocations: [Location]
    @Binding var recentActions: [InventoryAction]
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 18) {
            
            Text("Move \(items.count) items").font(.title2)
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
                
                ForEach(items.limit(11)) { item in
                    view(for: item)
                }
                
                if items.count > 11 {
                    Text("\(items.count-11) more")
                }
            }
            
            TextField("New location", text: $editLocation)
            
            if !recentMoveLocations.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("recent locations:")
                    HStack {
                        ForEach(recentMoveLocations, id: \.description) { loc in
                            Button(loc.description) {
                                editLocation = loc.description
                            }
                        }
                    }
                }
            }
            
            let newLocation = validatedLocation.valueToSubmit
            
            let itemsInNewLocation = inventoryStore.allInventories.filter { newLocation != nil && Location(from: $0.remarks) == newLocation }
            
            let conflictingItems: [InventoryItem] = items.flatMap { sourceItem in
                
                itemsInNewLocation
                    .filter({ $0.ref == sourceItem.ref && $0.condition != sourceItem.condition })
            }
            
            VStack(alignment: .leading) {
                
                if let loc = newLocation {
                    
                    Text("\(itemsInNewLocation.count) items in location \(loc)")
                
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
                        
                        ForEach(itemsInNewLocation.limit(11)) { item in
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
                        
                        if itemsInNewLocation.count > 11 {
                            Text("\(itemsInNewLocation.count-11) more")
                        }
                    }
                }
            }
            
            HStack {
                
                Button("Confirm move") {
                    if let loc = validatedLocation.valueToSubmit {
                        self.moveItems(to: loc)
                        self.addRecentLocation(loc)
                        self.addRecentMoveAction(to: loc)
                    }
                }
                .disabled(validatedLocation.valueToSubmit == nil)
                
                if validatedLocation.hasWarning {
                    Text("invalid location").foregroundStyle(.secondary)
                }
                if !conflictingItems.isEmpty {
                    Text("􀇿 conflicts detected").foregroundStyle(.orange)
                }
                
                if isUpdatingItems {
                    ProgressView().controlSize(.small)
                }
            }
        }
        .padding()
        .padding(.vertical)
        .onAppear {
            editLocation = defaultLocation?.description ?? ""
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
        defaultLocation: nil,
        recentMoveLocations: .constant([]),
        recentActions: .constant([])
    )
}
