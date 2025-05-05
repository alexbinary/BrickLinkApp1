
import SwiftUI



struct UploadRootView: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!

    
    @State var addViewVisible: Bool = false
    @State var selectedTab: String? = Defaults.active.uploadActiveTab
    
    
    var body: some View {
     
        TabView(selection: $selectedTab) {
            
            UploadView()
            .tabItem { Text("􀈧 Upload") }.tag("upload")
            
            UploadHistoryView()
            .tabItem { Text("􀐫 History") }.tag("history")
        }
        .navigationTitle("Upload")
        .task { await inventoryStore.softRefreshInventories() }
    }
}
