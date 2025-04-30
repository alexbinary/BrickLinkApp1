
import SwiftUI



struct InventoryMoveActionSheet: View {

    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let items: [InventoryItem]
    let defaultLocation: Location?
    
    
    @State var editLocation: String = ""
    
    @Binding var recentMoveLocations: [Location]
    
    
    let itemsLimit = 50
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 18) {
            
            HStack {
                Text("Move \(items.count) items").font(.title2)
                Spacer()
                Text("􀈫􁉂􀈫")
            }
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
                
                ForEach(items.limit(itemsLimit)) { item in
                    view(for: item)
                }
                
                if items.count > itemsLimit {
                    Text("\(items.count-itemsLimit) more")
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    TextField("New location", text: $editLocation)
                    
                    Button("Confirm move") {
                        if let loc = validatedLocation.valueToSubmit {
                            self.moveItems(to: loc)
                            self.addRecentLocation(loc)
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
            
            VStack(alignment: .leading, spacing: 4) {
                
                if !recentMoveLocations.isEmpty {
                    HStack {
                        Text("recent:")
                        HStack {
                            ForEach(recentMoveLocations.limit(4), id: \.description) { loc in
                                Button(loc.description) {
                                    editLocation = loc.description
                                }
                            }
                        }
                    }
                }
                
                let suggestedLocations = items
                    .flatMap { inventoryStore.suggestedTargetLocations(forMoving: $0) }
                    .unique.sorted().limit(4)
                
                if !suggestedLocations.isEmpty {
                    HStack {
                        Text("suggested:")
                        HStack {
                            ForEach(suggestedLocations, id: \.description) { loc in
                                Button(loc.description) {
                                    editLocation = loc.description
                                }
                            }
                        }
                    }
                }
            }
            
            let newLocation = validatedLocation.valueToSubmit
            
            InventoryLocationView(newLocation: newLocation, items: items)
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
        recentMoveLocations = recent.unique
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
    InventoryMoveActionSheet(
        items: [],
        defaultLocation: nil,
        recentMoveLocations: .constant([])
    )
}
