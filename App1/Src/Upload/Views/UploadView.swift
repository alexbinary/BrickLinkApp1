
import SwiftUI



struct UploadView: View {
    
    
    @Environment(InventoryController.self)
    var inventoryController

    
    @State var addViewVisible: Bool = false
    
    
    var body: some View {
     
        TabView {
            VStack {
                if addViewVisible { UploadAddView().padding() }
                ScrollView { UploadItemsView() }
            }
            .toolbar {
                Button { addViewVisible.toggle() }
                label: { Text("􀅼").padding(.horizontal) }
            }
            .tabItem { Text("􀋲 Upload") }.tag("upload")
            
            ScrollView { UploadedItemsView() }
            .tabItem { Text("􀐫 History") }.tag("history")
        }
        .navigationTitle("Upload")
        .onAppear {
            Task { await inventoryController.reloadInventories() }
        }
    }
}
