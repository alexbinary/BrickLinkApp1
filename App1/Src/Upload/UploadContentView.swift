
import SwiftUI



enum InventoryResult {
    
    case notFound
    case found(InventoryItem)
}



struct UploadContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @State var inventoryResult: InventoryResult? = nil
    @State var relatedInventories: [InventoryItem]? = nil
    
    @State var editQtyCreate: Int? = nil
    @State var editRemarksCreate: String = ""
    @State var editUnitPriceCreate: Float? = nil
    
    @State var editQtyUpdate: Int? = nil
    @State var editRemarksUpdate: String = ""
    @State var editUnitPriceUpdate: Float? = nil
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if let nextUploadItem = nextUploadItem {
                
                HeaderTitleView(label: "􀈧 Upload item")
                
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
                            Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                        }
                    }
                    
                    TableColumn("Comment", value: \.comment)
                    
                    TableColumn("") { item in
                    
                        Button {
                            appController.skipUploadItem(nextUploadItem)
                        } label: {
                            Text("Skip item")
                        }
                    }
                    
                } rows: {
                    
                    TableRow(nextUploadItem)
                }
                .frame(minHeight: 100, maxHeight: 100)
                
                if let inventoryResult = inventoryResult {
                    
                    switch inventoryResult {
                        
                    case .found(let inventoryItem):
                        
                        VStack(alignment: .leading) {
                            
                            Text("Found inventory")
                        
                            let qty = self.editQtyUpdate
                            let unitPrice = self.editUnitPriceUpdate
                            let remarks: String? = {
                                let trimmed = self.editRemarksUpdate.trimmingCharacters(in: .whitespacesAndNewlines)
                                if trimmed == "" {
                                    return nil
                                } else {
                                    return trimmed
                                }
                            }()
                        
                            HStack {
                                Text("Inventory update").font(.title3)
                                Link("#\(inventoryItem.id)", destination: URL(string: "https://www.bricklink.com/v2/inventory_detail.page?invID=\(inventoryItem.id)#/")!)
                            }
                                
                            Grid(alignment: .leading) {
                                
                                GridRow {
                                    Text("Qty").gridColumnAlignment(.trailing)
                                    TextField("Qty", value: $editQtyUpdate, format: .number)
                                    
                                    HStack {
                                        Text("Current:")
                                        Text("\(inventoryItem.quantity)")
                                    }
                                    
                                    Button {
                                        self.editQtyUpdate = nextUploadItem.qty
                                    } label: {
                                        Text("Reset")
                                    }
                                }
                                
                                GridRow {
                                    Text("Price").gridColumnAlignment(.trailing)
                                    TextField("Price", value: $editUnitPriceUpdate, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                    
                                    HStack {
                                        Text("Current:")
                                        Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                        Button {
                                            self.editUnitPriceUpdate = inventoryItem.unitPrice
                                        } label: {
                                            Text("Reset to current")
                                        }
                                    }
                                    
                                    Button {
                                        self.editUnitPriceUpdate = nextUploadItem.unitPrice
                                    } label: {
                                        Text("Reset")
                                    }
                                }
                                
                                GridRow {
                                    Text("Remarks").gridColumnAlignment(.trailing)
                                    TextField("Remarks", text: $editRemarksUpdate, prompt: Text("Required"))
                                    
                                    Color.clear.frame(width: 2, height: 2)
                                    
                                    Button {
                                        self.editRemarksUpdate = inventoryItem.remarks
                                    } label: {
                                        Text("Reset")
                                    }
                                }
                                
                                GridRow {
                                    
                                    Color.clear.frame(width: 2, height: 2)
                                    
                                    HStack {
                                        Button {
                                            Task {
                                                await appController.updateInventory(
                                                    id: inventoryItem.id,
                                                    addQuantity: qty!,
                                                    unitPrice: unitPrice!,
                                                    remarks: remarks!
                                                )
                                                appController.deleteUploadItem(nextUploadItem)
                                            }
                                        } label: {
                                            Text("Update inventory")
                                        }
                                        .disabled(qty == nil || unitPrice == nil || remarks == nil)
                                        
                                        let errors = {
                                            
                                            var errs = [String]()
                                            
                                            if qty == nil {
                                                
                                                errs.append("invalid qty")
                                            }
                                            if unitPrice == nil {
                                                
                                                errs.append("invalid unitPrice")
                                            }
                                            if remarks == nil {
                                                
                                                errs.append("missing remarks")
                                            }
                                            
                                            return errs
                                        }()
                                        
                                        if !errors.isEmpty {
                                            
                                            Text(errors.joined(separator: "; "))
                                                .foregroundStyle(.red)
                                        }
                                        
                                    }.gridCellColumns(2)
                                }
                            }
                        }
                        
                    case .notFound:
                        
                        VStack(alignment: .leading) {
                            
                            Text("No existing inventory found")
                            
                            let qty = self.editQtyCreate
                            let unitPrice = self.editUnitPriceCreate
                            let remarks: String? = {
                                let trimmed = self.editRemarksCreate.trimmingCharacters(in: .whitespacesAndNewlines)
                                if trimmed == "" {
                                    return nil
                                } else {
                                    return trimmed
                                }
                            }()
                            
                            Text("New inventory").font(.title3)
                            
                            Form {
                                
                                HStack {
                                    TextField("Qty", value: $editQtyCreate, format: .number)
                                    Button {
                                        self.editQtyCreate = nextUploadItem.qty
                                    } label: {
                                        Text("Reset")
                                    }
                                }
                                
                                HStack {
                                    TextField("Price", value: $editUnitPriceCreate, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                    Button {
                                        self.editUnitPriceCreate = nextUploadItem.unitPrice
                                    } label: {
                                        Text("Reset")
                                    }
                                }
                                
                                TextField("Remarks", text: $editRemarksCreate, prompt: Text("Required"))
                                
                                if let relatedInventories = self.relatedInventories {
                                    
                                    if relatedInventories.isEmpty {
                                        
                                        Text("no related inventory found")
                                        
                                    } else {
                                        
                                        let remarks = relatedInventories.map { $0.remarks }
                                            .unique .sorted()
                                        
                                        HStack {
                                            ForEach(remarks, id: \.self) { rem in
                                                Button {
                                                    self.editRemarksCreate = rem
                                                } label: {
                                                    Text(rem)
                                                }
                                            }
                                        }
                                    }
                                    
                                } else {
                                    
                                    Text("Loading related inventories...")
                                }
                                
                                HStack {
                                    
                                    Button {
                                        Task {
                                            await appController.createInventory(
                                                ref: nextUploadItem.ref,
                                                type: nextUploadItem.type,
                                                colorId: nextUploadItem.colorId,
                                                quantity: qty!,
                                                unitPrice: unitPrice!,
                                                condition: nextUploadItem.condition,
                                                description: nextUploadItem.comment,
                                                remarks: remarks!
                                            )
                                            appController.deleteUploadItem(nextUploadItem)
                                        }
                                    } label: {
                                        Text("Create inventory")
                                    }
                                    .disabled(qty == nil || unitPrice == nil || remarks == nil)
                                    
                                    let errors = {
                                    
                                        var errs = [String]()
                                        
                                        if qty == nil {
                                            
                                            errs.append("invalid qty")
                                        }
                                        if unitPrice == nil {
                                            
                                            errs.append("invalid unitPrice")
                                        }
                                        if remarks == nil {
                                            
                                            errs.append("missing remarks")
                                        }
                                        
                                        return errs
                                    }()
                                    
                                    if !errors.isEmpty {
                                        
                                        Text(errors.joined(separator: "; "))
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    
                    Text("Loading inventory...")
                }
                
                Divider()
            }
            
            UploadListView()
        }
        .onAppear {
            Task {
                await self.pullInventory()
            }
        }
        .onChange(of: nextUploadItem) {
            Task {
                await self.pullInventory()
            }
        }
        .padding()
        .navigationTitle("Upload")
    }
    
    
    var nextUploadItem: UploadItem? {
        
        return appController.uploadItems.first
    }
    
    
    func pullInventory() async {
        
        guard let nextUploadItem = nextUploadItem else { return }
        
        self.inventoryResult = nil
        self.relatedInventories = nil
        
        if let item = await appController.getInventory(for: nextUploadItem) {
            
            self.inventoryResult = .found(item)
            
            self.editQtyUpdate = nextUploadItem.qty
            self.editUnitPriceUpdate = nextUploadItem.unitPrice
            self.editRemarksUpdate = item.remarks
            
        } else {
            
            self.inventoryResult = .notFound
            
            self.editQtyCreate = nextUploadItem.qty
            self.editUnitPriceCreate = nextUploadItem.unitPrice
            self.editRemarksCreate = ""
            
            self.relatedInventories = await appController.getInventoriesForAllColors(for: nextUploadItem)
        }
    }
}
