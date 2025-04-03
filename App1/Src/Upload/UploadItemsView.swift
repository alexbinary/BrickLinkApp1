
import SwiftUI
import Core



struct UploadItemsView: View {
    
    
    @Environment(UploadStore.self)
    var uploadStore
    
    @Environment(InventoryStore.self)
    var inventoryStore
    

    var body: some View {

        let items = uploadStore.uploadItemsForList
        
        LazyVStack(alignment: .leading, spacing: 12, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(items) { UploadItemView(uploadItem: $0).padding([.leading, .trailing]) }
                Color.clear.frame(width: 0, height: 24)
            } header: {
                SectionHeader("􀋲 Items to upload", secondaryText: "\(items.count) items")
            }
        }
        .task {
            await inventoryStore.refreshInventories(.refetchOnlyIfInvalidated)
        }
        .toolbar {
            Menu {
                Button("Reload inventory (soft)") { Task { await inventoryStore.refreshInventories(.refetchOnlyIfInvalidated) } }
                Button("Reload inventory (hard)") { Task { await inventoryStore.refreshInventories(.forceRefetch) } }
            } label: { Text("􀅈").padding(.horizontal) }
            primaryAction: { Task { await inventoryStore.reloadInventories() } }
        }
    }
}



#Preview {
    
    let env = createEnv()
    
    UploadItemsView()
        .inject(env)
}
