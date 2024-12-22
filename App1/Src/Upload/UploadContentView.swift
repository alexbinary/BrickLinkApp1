
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
                                Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            }
                        }
                        
                        TableColumn("Comment", value: \.comment)
                        
                    } rows: {
                        
                        TableRow(nextUploadItem)
                    }
                    .frame(minHeight: 100)
                    
                    Button {
                        Task {
                            self.inventoryItem = await appController.getInventory(for: nextUploadItem)
                        }
                    } label: {
                        Text("Pull inventory")
                    }
                    
                    if let inventoryItem = self.inventoryItem {
                        
                        HStack {
                            
                            VStack(alignment: .leading) {
                                
                                HStack {
                                    Text("ID:")
                                    Text(inventoryItem.id)
                                }
                                HStack {
                                    Text("Ref:")
                                    Text(inventoryItem.ref)
                                }
                                HStack {
                                    Text("Name:")
                                    Text(inventoryItem.name)
                                }
                                HStack {
                                    Text("Color:")
                                    appController.color(forLegoColorId: inventoryItem.colorId).frame(width: 18, height: 18)
                                    Text(appController.colorName(forLegoColorId: inventoryItem.colorId))
                                }
                                HStack {
                                    Text("Condition:")
                                    Text(inventoryItem.condition)
                                }
                                HStack {
                                    Text("Description:")
                                    Text(inventoryItem.description)
                                }
                                HStack {
                                    Text("Remarks:")
                                    Text(inventoryItem.remarks)
                                }
                                HStack {
                                    Text("Qty:")
                                    Text(inventoryItem.quantity, format: .number)
                                }
                                HStack {
                                    Text("PU:")
                                    Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode))
                                }
                            }
                            
                            AsyncImage(url: appController.imageUrl(forItemType: inventoryItem.type, ref: inventoryItem.ref, colorId: inventoryItem.colorId))
                                .frame(maxWidth: 100, maxHeight: 100)
                        }
                        
                        Button {
                            
                            let remarks = ""
                            
                            Task {
                                await appController.updateInventory(
                                    id: inventoryItem.id,
                                    addQuantity: nextUploadItem.qty,
                                    unitPrice: nextUploadItem.unitPrice,
                                    remarks: remarks
                                )
                            }
                        } label: {
                            Text("Update inventory")
                        }
                        
                    } else {
                        
                        Text("No inventory")
                        
                        if let unitPrice = nextUploadItem.unitPrice, unitPrice > 0 {
                            
                            Button {
                                
                                let remarks = ""
                                
                                Task {
                                    await appController.createInventory(
                                        ref: nextUploadItem.ref,
                                        type: nextUploadItem.type,
                                        colorId: nextUploadItem.colorId,
                                        quantity: nextUploadItem.qty,
                                        unitPrice: unitPrice,
                                        condition: nextUploadItem.condition,
                                        description: nextUploadItem.comment,
                                        remarks: remarks
                                    )
                                }
                            } label: {
                                Text("Create inventory")
                            }
                            
                        } else {
                            
                            Text("cannot create inventory, invalid unitPrice")
                        }
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
