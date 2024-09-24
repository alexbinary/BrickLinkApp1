
import SwiftUI



struct UploadContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var inventoryItem: InventoryItem? = nil
    
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading) {
                
                UploadListView()
                
                Divider()
                
                if let nextUploadItem = nextUploadItem {
                    
                    HeaderTitleView(label: "􀈧 Inventory")
                    
                    Table(of: UploadItem.self) {
                        
                        TableColumn("Image") { item in
                            AsyncImage(url: appController.imageUrl(forItemType: item.type, ref: item.ref, colorId: item.colorId))
                                .frame(minHeight: 60)
                        }
                        
                        TableColumn("Condition", value: \.condition)
                        
                        TableColumn("Color") { item in
                            HStack {
                                appController.color(forLegoColorId: item.colorId).frame(width: 18, height: 18)
                                Text(appController.colorName(forLegoColorId: item.colorId))
                            }
                        }
                        
                        TableColumn("Ref", value: \.ref)
                        
                        TableColumn("Quantity") { item in
                            Text(item.qty, format: .number)
                        }
                        
                        TableColumn("Price") { item in
                            if let price = item.unitPrice {
                                Text(price, format: .number)
                            }
                        }
                        
                        TableColumn("Comment", value: \.comment)
                        
                        TableColumn("Remarks") { item in
                            Text(item.remarks ?? "")
                        }
                        
                    } rows: {
                        
                        TableRow(nextUploadItem)
                    }
                    .frame(minHeight: 100)
                    
                    Button {
                        Task {
                            await appController.createInventory(from: nextUploadItem)
                        }
                    } label: {
                        Text("Create inventory")
                    }
                    
                    Button {
                        Task {
                            self.inventoryItem = await appController.getInventory(for: nextUploadItem)
                        }
                    } label: {
                        Text("Pull inventory")
                    }
                    
                    if let inventoryItem = self.inventoryItem {
                        
                        Text(inventoryItem.id)
                        
                        Button {
                            Task {
                                await appController.updateInventory(inventoryItem , from: nextUploadItem)
                            }
                        } label: {
                            Text("Update inventory")
                        }
                        
                    } else {
                        Text("No inventory")
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Upload")
    }
    
    
    var nextUploadItem: UploadItem? {
        
        return appController.uploadItems.first
    }
}
