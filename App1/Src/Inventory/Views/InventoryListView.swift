
import SwiftUI



struct InventoryListView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    @State var searchText = ""
    @State var searchTokens: [SearchToken] = []
    
    @State var actionPopoverPresented: Bool = false
    @State var recentMoveLocations: [Location] = []
    
 
    var body: some View {
        
        let inventories = inventoryStore.allInventories(matching: searchText, searchTokens)
        
        let searchSuggestions: [SearchSuggestion] = {
            
            if searchText.isEmpty {
                return []
            }
            
            var suggestions: [SearchSuggestion] = []
            
            // ref
            
            let matchingRefs = inventories.map(\.ref).filter { $0.lowercased().contains(searchText.lowercased()) }
            
            for ref in matchingRefs.unique.sorted().limit(10) {
                suggestions.append(.token(.refIs(ref)))
            }
            if !matchingRefs.isEmpty {
                suggestions.append(.token(.refContains(searchText)))
            }
            
            // location
            
            let matchingLocations = inventories.compactMap { Location(from: $0.remarks) }.filter { $0.description.lowercased().contains(searchText.lowercased()) }
            
            for location in matchingLocations.unique.sorted().limit(10) {
                suggestions.append(.token(.locationIs(location)))
            }
            if !matchingLocations.isEmpty {
                suggestions.append(.token(.locationContains(searchText)))
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
            
            Button {
                actionPopoverPresented = true
            } label: {
                Text("􀈫􁉂").padding(.horizontal)
            }
            .popover(isPresented: $actionPopoverPresented, arrowEdge: .bottom) {
                InventoryActionSheet(
                    items: inventories,
                    defaultLocation: nil,
                    recentMoveLocations: $recentMoveLocations
                )
            }
            .disabled(inventories.isEmpty)
        }
        .task { await inventoryStore.softRefreshInventories() }
    }
    
    
    @ViewBuilder
    func suggestionView(for token: SearchToken) -> some View {
        
        switch token {
            
        case .locationIs(let location):
            
            HStack(spacing: 0) {
                Text("􁼡 Location ").foregroundColor(.secondary)
                Text(location.description)
            }
            
        case .locationContains(let str):
            
            HStack(spacing: 0) {
                Text("􁼡 Locations that contain \"").foregroundColor(.secondary)
                Text(str)
                Text("\"").foregroundColor(.secondary)
            }
            
        case .refIs(let ref):
            
            HStack(spacing: 0) {
                Text("􂘬 Ref ").foregroundColor(.secondary)
                Text(ref)
            }
            
        case .refContains(let str):
            
            HStack(spacing: 0) {
                Text("􂘬 Refs that contain \"").foregroundColor(.secondary)
                Text(str)
                Text("\"").foregroundColor(.secondary)
            }
        }
    }
    
    
    @ViewBuilder
    func tokenView(for token: SearchToken) -> some View {
        
        switch token {
            
        case .locationIs(let location):
            Text("􁼡 \(location)")
            
        case .locationContains(let str):
            Text("􁼡 \"\(str)\"")
            
        case .refIs(let ref):
            Text("􂘬 \(ref)")
            
        case .refContains(let str):
            Text("􂘬 \"\(str)\"")
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
