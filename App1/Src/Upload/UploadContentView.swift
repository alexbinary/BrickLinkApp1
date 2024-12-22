
import SwiftUI



enum InventoryResult {
    
    case notFound
    case found(InventoryItem)
}



struct UploadContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var inventoryResult: InventoryResult? = nil
    
    @State var qty: Int? = nil
    @State var remarks: String = ""
    @State var unitPrice: Float? = nil
    
    
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
                    
                    if let inventoryResult = inventoryResult {
                        
                        switch inventoryResult {
                         
                        case .found(let inventoryItem):
                            
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
                            
                            let remarks: String? = {
                                if self.remarks.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                    return self.remarks
                                }
                                return nil
                            }()
                            let qty = self.qty ?? nextUploadItem.qty
                            let unitPrice = self.unitPrice ?? {
                                if (nextUploadItem.unitPrice ?? 0) > 0 {
                                    return nextUploadItem.unitPrice
                                }
                                return nil
                            }()
                            
                            VStack(alignment: .leading) {
                                
                                Text("Will update inventory with:").font(.title3)
                                
                                HStack {
                                    Text("Remarks:")
                                    if let remarks = remarks {
                                        Text(remarks)
                                    } else {
                                        Text("UNCHANGED")
                                    }
                                }
                                HStack {
                                    Text("ΔQty:")
                                    Text(qty, format: .number)
                                }
                                HStack {
                                    Text("PU:")
                                    if let unitPrice = unitPrice {
                                        Text(unitPrice, format: .currency(code: "EUR").presentation(.isoCode))
                                    } else {
                                        Text("UNCHANGED")
                                    }
                                }
                            }
                            
                            Button {
                                
                                Task {
                                    await appController.updateInventory(
                                        id: inventoryItem.id,
                                        addQuantity: qty,
                                        unitPrice: unitPrice,
                                        remarks: remarks
                                    )
                                }
                            } label: {
                                Text("Update inventory")
                            }
                            
                        case .notFound:
                            
                            Text("No inventory")
                            
                            let remarks: String? = {
                                if self.remarks.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                    return self.remarks
                                }
                                return nil
                            }()
                            let qty = self.qty ?? nextUploadItem.qty
                            let unitPrice = self.unitPrice ?? {
                                if (nextUploadItem.unitPrice ?? 0) > 0 {
                                    return nextUploadItem.unitPrice
                                }
                                return nil
                            }()
                            
                            VStack(alignment: .leading) {
                                
                                Text("Will create inventory with:").font(.title3)
                                
                                HStack {
                                    Text("Remarks:")
                                    if let remarks = remarks {
                                        Text(remarks)
                                    } else {
                                        Text("MISSING")
                                    }
                                }
                                HStack {
                                    Text("Qty:")
                                    Text(qty, format: .number)
                                }
                                HStack {
                                    Text("PU:")
                                    if let unitPrice = unitPrice {
                                        Text(unitPrice, format: .currency(code: "EUR").presentation(.isoCode))
                                    } else {
                                        Text("INVALID")
                                    }
                                }
                            }
                            
                            if remarks == nil {
                                
                                Text("cannot create inventory, missing remarks")
                                
                            } else if unitPrice == nil {
                                
                                Text("cannot create inventory, invalid unitPrice")
                                
                            } else {
                                
                                Button {
                                    
                                    Task {
                                        await appController.createInventory(
                                            ref: nextUploadItem.ref,
                                            type: nextUploadItem.type,
                                            colorId: nextUploadItem.colorId,
                                            quantity: qty,
                                            unitPrice: unitPrice!,
                                            condition: nextUploadItem.condition,
                                            description: nextUploadItem.comment,
                                            remarks: remarks!
                                        )
                                    }
                                } label: {
                                    Text("Create inventory")
                                }
                            }
                        }
                        
                        Form {
                            
                            TextField("Qty", value: $qty, format: .number)
                            
                            TextField("Price", value: $unitPrice, format: .currency(code: "EUR").presentation(.isoCode))
                            
                            TextField("Remarks", text: $remarks)
                        }
                        
                    } else {
                        
                        Button {
                            Task {
                                let item = await appController.getInventory(for: nextUploadItem)
                                if let item = item {
                                    self.inventoryResult = .found(item)
                                } else {
                                    self.inventoryResult = .notFound
                                }
                            }
                        } label: {
                            Text("Pull inventory")
                        }
                    }
                    
                    Button {
                        
                        Task {
                            appController.deleteUploadItem(nextUploadItem)
                            
                            self.inventoryResult = nil
                            
                            self.qty = nil
                            self.remarks = ""
                            self.unitPrice = nil
                        }
                    } label: {
                        Text("Done")
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
