
import SwiftUI



struct UploadContentView: View {
    
    
    @EnvironmentObject var appController: AppController

    @State var type: BrickLinkItemType = .part
    @State var ref: String = ""
    @State var colorId: LegoColor.ID = ""
    @State var qty: Int = 1
    @State var condition: String = "U"
    @State var comment: String = ""
    @State var remarks: String = ""
    @State var unitPrice: Float = 0
    
    @State var inventoryItem: InventoryItem? = nil
    
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading) {
                
                HeaderTitleView(label: "􀋲 Upload list")
                
                HStack {
                    
                    Form {
                        
                        Picker("Type", selection: $type) {
                            
                            ForEach(BrickLinkItemType.allCases, id: \.self) { type in
                                
                                Text(type.rawValue).tag(type)
                            }
                        }
                        
                        TextField("Ref", text: $ref)
                        
                        Picker("Color", selection: $colorId) {
                            
                            ForEach(appController.allColors) { color in
                                
                                Text(color.name).foregroundStyle(Color(fromBLCode: color.colorCode))
                                    .tag(color.id)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        TextField("Qty", value: $qty, format: .number)
                        
                        TextField("Price", value: $unitPrice, format: .number)
                        
                        Picker("Condition", selection: $condition) {
                            
                            Text("New").tag("N")
                            Text("Used").tag("U")
                        }
                        
                        TextField("Comment", text: $comment)
                        TextField("Remarks", text: $remarks)
                        
                        Button {
                            appController.addUploadItem(UploadItem(
                                type: type,
                                ref: ref,
                                colorId: colorId,
                                qty: qty,
                                condition: condition,
                                comment: comment,
                                remarks: remarks,
                                unitPrice: unitPrice
                            ))
                        } label: {
                            Text("Add")
                        }
                    }
                    
                    AsyncImage(url: appController.imageUrl(forItemType: type, ref: ref, colorId: colorId))
                        .frame(maxWidth: 100, maxHeight: 100)
                }
                
                Table(appController.uploadItems) {
                    
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
                    
                    TableColumn("Delete") { item in
                        Button {
                            appController.deleteUploadItem(item)
                        } label: {
                            Text("Delete")
                        }
                    }
                }
                .frame(minHeight: 400)
                
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
