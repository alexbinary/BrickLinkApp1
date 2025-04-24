
import SwiftUI



struct InventoryListView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    @State var searchText = ""
    @State var searchTokens: [SearchToken] = []
    @State var actionPopoverPresented: Bool = false
    
    @State var recentMoveLocations: [Location] = []
    @State var recentActions: [InventoryAction] = []
    
 
    var body: some View {
        
        let inventories = inventoryStore.allInventories(matching: searchText, searchTokens)
        
        let searchSuggestions: [SearchSuggestion] = {
            
            if searchText.isEmpty {
                return []
            }
            
            var suggestions: [SearchSuggestion] = []
            
            let matchingLocations = inventories.compactMap { Location(from: $0.remarks) }.filter { $0.description.contains(searchText) }
            
            if !matchingLocations.isEmpty {
                suggestions.append(.token(.locationContains(searchText)))
            }
            for location in matchingLocations.unique.sorted() {
                suggestions.append(.token(.locationIs(location)))
            }
            
            return suggestions
        }()
           
        ScrollView {
            
            LazyVStack(alignment: .leading, spacing: 12) {
                
                ForEach(inventories) { item in
                    
                    InventoryItemView(item: item, listSearchText: $searchText, listSearchTokens: $searchTokens)
                        .padding(.horizontal)
                }
            }
            .searchable(text: $searchText, tokens: $searchTokens, prompt: "Search inventories") { tokenView(for: $0) }
            .searchSuggestions {
                ForEach(searchSuggestions, id: \.description) {
                    switch $0 {
                    case .token(let token):
                        suggestionView(for: token).searchCompletion(token)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Inventory")
        .navigationSubtitle("\(inventories.count) lots, \(inventories.reduce(0, { $0+$1.quantity })) items")
        .toolbar {
            Menu {
                if recentActions.isEmpty {
                    Text("no recent actions")
                } else {
                    ForEach(recentActions, id: \.description) { action in
                        Button(action.description) {
                            self.run(action, on: inventories)
                        }
                    }
                }
            } label: {
                Text("􀈫").padding(.horizontal)
            } primaryAction: {
                actionPopoverPresented.toggle()
            }
            .popover(isPresented: $actionPopoverPresented, arrowEdge: .bottom) {
                InventoryActionSheet(
                    items: inventories,
                    recentMoveLocations: $recentMoveLocations,
                    recentActions: $recentActions
                )
            }
        }
        .task { await inventoryStore.softRefreshInventories() }
    }
    
    
    func run(_ action: InventoryAction, on items: [InventoryItem]) {
        
        switch action {
        case .move(let location):
            move(items, to: location)
        }
    }
    
    
    func move(_ items: [InventoryItem], to loc: Location) {
        
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
    
    
    @ViewBuilder
    func suggestionView(for token: SearchToken) -> some View {
        
        switch token {
            
        case .locationIs(let location):
            
            HStack(spacing: 0) {
                Text("􀈣 Location is ").foregroundColor(.secondary)
                Text(location.description)
            }
            
        case .locationContains(let str):
            
            HStack(spacing: 0) {
                Text("􀈣 Location contains ").foregroundColor(.secondary)
                Text(str)
            }
        }
    }
    
    
    @ViewBuilder
    func tokenView(for token: SearchToken) -> some View {
        
        switch token {
            
        case .locationIs(let location):
            Text("Location is: \(location)")
            
        case .locationContains(let str):
            Text("Location contains: \(str)")
        }
    }
}



enum InventoryAction: Equatable {
    
    case move(to: Location)
    
    var description: String {
        switch self {
        case .move(let location):
            "Move items to \(location)"
        }
    }
}



#Preview {
    
    NavigationSplitView {
        
    } detail: {
        
        InventoryListView()
    }
    .previewEnv()
}
