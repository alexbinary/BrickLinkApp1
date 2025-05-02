
import SwiftUI



struct InventoryMoveActionSheet: View {

    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
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
            
            InventoryLocationItemsView(items: items, itemViewBuilder: { item, view in AnyView(view) })
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    TextField("New location", text: $editLocation)
                    
                    Button("Confirm move") {
                        if let loc = validatedLocation.submitValue {
                            self.moveItems(to: loc)
                            self.addRecentLocation(loc)
                        }
                    }
                    .disabled(validatedLocation.submitValue == nil)
                }
                
                if isUpdatingItems || validatedLocation.isInvalid {
                    
                    HStack {
                        
                        if isUpdatingItems {
                            ProgressView().controlSize(.small)
                        }
                        
                        Spacer()
                        
                        if validatedLocation.isInvalid {
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
            
            let newLocation = validatedLocation.submitValue
            
            InventoryTargetLocationView(newLocation: newLocation, candidateItems: items)
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
            .init(submitValue: loc, isInvalid: false)
        } else if editLocation.isEmpty {
            .init(submitValue: nil, isInvalid: false)
        } else {
            .init(submitValue: nil, isInvalid: true)
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
