
import SwiftUI



struct UploadRootView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!

    
    @State var addViewVisible: Bool = false
    
    
    var body: some View {
     
        TabView(
            selection: .constant("upload")
        ) {
            
            UploadAddView()
            .tabItem { Text("􀋲 Prepare") }.tag("add")
            
            UploadView()
            .tabItem { Text("􀈧 Upload") }.tag("upload")
            
            UploadHistoryView()
            .tabItem { Text("􀐫 History") }.tag("history")
        }
        .navigationTitle("Upload")
        .task { await inventoryStore.softRefreshInventories() }
    }
}
