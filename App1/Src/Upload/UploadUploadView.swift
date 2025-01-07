
import SwiftUI



enum Result<T> {
    
    case notFound
    case found(T)
}



struct UploadUploadView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedItemId: UploadItem.ID?
    
    @State var catalogResult: Result<CatalogItem>? = nil
    @State var inventoryResult: Result<InventoryItem>? = nil
    @State var relatedInventories: [InventoryItem]? = nil
    
    @State var editQtyCreate: Int? = nil
    @State var editRemarksCreate: String = ""
    @State var editUnitPriceCreate: Float? = nil
    
    @State var editQtyUpdate: Int? = nil
    @State var editRemarksUpdate: String = ""
    @State var editUnitPriceUpdate: Float? = nil
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if let activeUploadItem = activeUploadItem {
                
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
                    
                        HStack {
                            Button {
                                appController.skipUploadItem(activeUploadItem)
                            } label: {
                                Text("􁉂 Skip")
                            }
                            Button {
                                appController.deleteUploadItem(item)
                            } label: {
                                Text("􀈑 Delete")
                            }
                        }
                    }
                    
                } rows: {
                    
                    TableRow(activeUploadItem)
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
                            
                            Text(inventoryItem.name.htmlUnescape()).font(.title3)
                            Text(inventoryItem.description).foregroundStyle(.secondary)
                                
                            Grid(alignment: .leading) {
                                
                                GridRow {
                                    Text("Qty").gridColumnAlignment(.trailing)
                                    TextField("Qty", value: $editQtyUpdate, format: .number)
                                    
                                    HStack {
                                        Text("Current:")
                                        Text("\(inventoryItem.quantity)")
                                    }
                                    
                                    Button {
                                        self.editQtyUpdate = activeUploadItem.qty
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
                                        self.editUnitPriceUpdate = activeUploadItem.unitPrice
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
                                    Text("")
                                    
                                    if let relatedInventories = self.relatedInventories {
                                        
                                        if relatedInventories.isEmpty {
                                            
                                            Text("no related inventory found")
                                            
                                        } else {
                                            
                                            let remarks = relatedInventories.map { $0.remarks }
                                                .unique .sorted()
                                            
                                            HStack {
                                                ForEach(remarks, id: \.self) { rem in
                                                    Button {
                                                        self.editRemarksUpdate = rem
                                                    } label: {
                                                        Text(rem)
                                                    }
                                                }
                                            }
                                        }
                                        
                                    } else {
                                        
                                        Text("Loading related inventories...")
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
                                                appController.deleteUploadItem(activeUploadItem)
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
                            
                            if let catalogResult = catalogResult {
                                
                                switch catalogResult {
                                    
                                case .found(let catalogItem):
                                    
                                    Text(catalogItem.name).font(.title3)
                                    
                                case .notFound:
                                    
                                    Text("Catalog entry not found")
                                }
                                
                            } else {
                                
                                Text("Loading catalog...")
                            }
                            
                            Text(activeUploadItem.comment).foregroundStyle(.secondary)
                            
                            Form {
                                
                                HStack {
                                    TextField("Qty", value: $editQtyCreate, format: .number)
                                    Button {
                                        self.editQtyCreate = activeUploadItem.qty
                                    } label: {
                                        Text("Reset")
                                    }
                                }
                                
                                HStack {
                                    TextField("Price", value: $editUnitPriceCreate, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                    Button {
                                        self.editUnitPriceCreate = activeUploadItem.unitPrice
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
                                                ref: activeUploadItem.ref,
                                                type: activeUploadItem.type,
                                                colorId: activeUploadItem.colorId,
                                                quantity: qty!,
                                                unitPrice: unitPrice!,
                                                condition: activeUploadItem.condition,
                                                description: activeUploadItem.comment,
                                                remarks: remarks!
                                            )
                                            appController.deleteUploadItem(activeUploadItem)
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
                
                Spacer()
                
            } else {
                
                Text("Nothing to upload")
            }
        }
        .onAppear {
            Task {
                await self.pullInventory()
            }
        }
        .onChange(of: activeUploadItem) {
            Task {
                await self.pullInventory()
            }
        }
        .padding()
    }
    
    
    var activeUploadItem: UploadItem? {
        
        if let id = selectedItemId,
           let item = appController.uploadItems.first(where: { $0.id == id }) {
            
            return item
        }
        
        return appController.uploadItems.first
    }
    
    
    func pullInventory() async {
        
        guard let activeUploadItem = activeUploadItem else { return }
        
        self.inventoryResult = nil
        self.relatedInventories = nil
        
        await parallel([
            {
                if let item = await appController.getInventory(for: activeUploadItem) {
                    
                    self.inventoryResult = .found(item)
                    
                    self.editQtyUpdate = activeUploadItem.qty
                    self.editUnitPriceUpdate = activeUploadItem.unitPrice
                    self.editRemarksUpdate = item.remarks
                    
                } else {
                    
                    self.inventoryResult = .notFound
                    
                    self.editQtyCreate = activeUploadItem.qty
                    self.editUnitPriceCreate = activeUploadItem.unitPrice
                    self.editRemarksCreate = ""
                    
                    self.catalogResult = nil
                    
                    if let catalog = await appController.getCatalogItem(for: activeUploadItem) {
                        
                        self.catalogResult = .found(catalog)
                    } else {
                        self.catalogResult = .notFound
                    }
                }
            },
            {
                self.relatedInventories = await appController.getInventoriesForAllColors(for: activeUploadItem)
            }
        ])
    }
}
