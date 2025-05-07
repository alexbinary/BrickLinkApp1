
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
            
            ScrollView {
                
                InventoryLocationItemsView(items: items, splitByRemarks: true, itemViewBuilder: { item, view in AnyView(view) })
            }
            .frame(minHeight: 270)
            
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
            
            let newLocation = validatedLocation.submitValue
            
            ScrollView {
                
                InventoryTargetLocationView(newLocation: newLocation, candidateItems: items.map(\.partDescriptor))
            }
            .frame(minHeight: 270)
        }
        .padding()
        .onAppear {
            editLocation = defaultLocation?.description ?? ""
        }
        .frame(minWidth: 400)
    }
    
    
    var validatedLocation: ValidatedValue<Location> {
        
        if let loc = Location(from: editLocation) {
            .init(submitValue: loc, validity: .valid, hasWarning: false)
        } else if editLocation.isEmpty {
            .init(submitValue: nil, validity: .valid, hasWarning: false)
        } else {
            .init(submitValue: nil, validity: .invalid, hasWarning: true)
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
