
import SwiftUI



enum Result<T> {
    
    case notFound
    case found(T)
}



struct UploadUploadView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var selectedItemId: UploadItem.ID?
    
    @State var catalogResult: Result<CatalogItem>? = nil
    @State var inventoryResult: Result<InventoryItem>? = nil
    @State var relatedInventories: [InventoryItem]? = nil
    
    @State var editRef: String = ""
    @State var editColorId: LegoColor.ID = ""
    @State var editCondition: String = "U"
    @State var editComment: String = ""
    @State var editQty: Int?
    @State var editUnitPrice: Float?
    @State var editRemarks: String = ""
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if let activeUploadItem = activeUploadItem {
                
                HStack(alignment: .top, spacing: 48) {
                    
                    Grid(alignment: .leading) {
                        
                        let status: (isLoadingInventory: Bool, inventoryItem: InventoryItem?) = {
                        
                            if let inventoryResult = inventoryResult {
                                
                                switch inventoryResult {
                                    
                                case .found(let inventoryItem):
                                    return (isLoadingInventory: false, inventoryItem: inventoryItem)
                                    
                                case .notFound:
                                    return (isLoadingInventory: false, inventoryItem: nil)
                                }
                            } else {
                                return (isLoadingInventory: true, inventoryItem: nil)
                            }
                        }()
                        
                        let submitType = activeUploadItem.type
                        let submitRef = editRef.normalizedOptional
                        let submitColorId = editColorId
                        let sbmitCondition = editCondition
                        let submitComment = editComment
                        let submitQty = editQty.normalizedOptional
                        let submitUnitPrice = editUnitPrice.normalizedOptional
                        let submitRemarks = editRemarks.normalizedOptional
                        
                        GridRow {
                            Text("Ref")
                            HStack {
                                TextField("Ref", text: $editRef)
                                if submitRef == nil {
                                    Text("cannot be empty")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        
                        GridRow {
                            Text("Name")
                            Group {
                                if let catalogResult = catalogResult {
                                    
                                    switch catalogResult {
                                        
                                    case .found(let catalogItem):
                                        Text(catalogItem.name).lineLimit(nil)
                                        
                                    case .notFound:
                                        Text("no catalog entry").foregroundStyle(.secondary)
                                    }
                                    
                                } else {
                                    Text("Loading name from catalog...").foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        GridRow {
                            Text("Comment")
                            TextField("Comment", text: $editComment)
                        }
                        
                        GridRow {
                            Text("Condition")
                            Picker("Condition", selection: $editCondition) {
                                
                                Text("NEW").tag("N")
                                Text("USED").tag("U")
                            }
                            .labelsHidden()
                        }
                        
                        GridRow {
                            Text("Color")
                            HStack {
                                appController.color(forLegoColorId: editColorId).frame(width: 18, height: 18)
                                Picker("Color", selection: $editColorId) {
                                    
                                    ForEach(appController.allColors) { color in
                                        
                                        Text(color.name).foregroundStyle(Color(fromBLCode: color.colorCode))
                                            .tag(color.id)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                        }
                        
                        GridRow {
                            Text("Qty")
                            HStack {
                                TextField("Qty", value: $editQty, format: .number)
                                if let inventoryItem = status.inventoryItem {
                                    Text("Current: \(inventoryItem.quantity)")
                                }
                                if submitQty == nil {
                                    Text("must be at least 1")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        
                        GridRow {
                            Text("Price")
                            HStack {
                                TextField("Price", value: $editUnitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                if let inventoryItem = status.inventoryItem {
                                    if let price = submitUnitPrice, price != inventoryItem.unitPrice {
                                        Button {
                                            self.editUnitPrice = nil
                                        } label: {
                                            Text("Keep existing")
                                            Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                        }
                                    }
                                }
                                if submitUnitPrice == nil {
                                    Text("must not be zero")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        
                        GridRow {
                            Text("Remarks")
                            HStack {
                                TextField("Remarks", text: $editRemarks, prompt: Text("Required"))
                            
                                if let relatedInventories = self.relatedInventories {
                                    
                                    if relatedInventories.isEmpty {
                                        
                                        Text("no related inventory found").foregroundStyle(.secondary)
                                        
                                    } else {
                                        
                                        let remarks = relatedInventories.map { $0.remarks }
                                            .unique .sorted()
                                        
                                        HStack {
                                            ForEach(remarks, id: \.self) { rem in
                                                Button {
                                                    self.editRemarks = rem
                                                } label: {
                                                    Text(rem)
                                                }
                                            }
                                        }
                                    }
                                    
                                } else {
                                    
                                    Text("Loading related inventories...").foregroundStyle(.secondary)
                                }
                                
                                if submitRemarks == nil {
                                    Text("cannot be empty")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        
                        if status.isLoadingInventory {
                            
                            Text("Checking inventory...").foregroundStyle(.secondary)
                                .padding(.vertical)
                            
                        } else {
                            
                            if let inventoryItem = status.inventoryItem {
                                
                                HStack {
                                    Text("Will update")
                                    Link("#\(inventoryItem.id)", destination: URL(string: "https://www.bricklink.com/v2/inventory_detail.page?invID=\(inventoryItem.id)#/")!)
                                }
                                .padding(.vertical)
                                
                            } else {
                                
                                Text("Will create new inventory")
                                    .padding(.vertical)
                            }
                        }
                        
                        GridRow {
                            
                            Color.clear.frame(width: 2, height: 2)
                            
                            HStack {
                                
                                let buttonDisabled = status.isLoadingInventory
                                || submitRef == nil
                                || submitQty == nil
                                || submitUnitPrice == nil
                                || submitRemarks == nil
                                
                                Button {
                                    
                                    if let inventoryItem = status.inventoryItem {
                                        
                                        Task {
                                            await appController.updateInventory(
                                                id: inventoryItem.id,
                                                addQuantity: submitQty!,
                                                unitPrice: submitUnitPrice!,
                                                remarks: submitRemarks!
                                            )
                                            appController.addUploadedItem(UploadedItem(
                                                type: submitType,
                                                ref: submitRef!,
                                                colorId: submitColorId,
                                                qty: submitQty!,
                                                condition: sbmitCondition,
                                                comment: submitComment,
                                                remarks: submitRemarks!,
                                                unitPrice: submitUnitPrice!,
                                                inventoryId: inventoryItem.id,
                                                uploadDate: .now
                                            ))
                                            goToNextItem(deleteActiveItem: true)
                                        }
                                        
                                    } else {
                                        
                                        Task {
                                            if let inventoryItem = await appController.createInventory(
                                                ref: submitRef!,
                                                type: submitType,
                                                colorId: submitColorId,
                                                quantity: submitQty!,
                                                unitPrice: submitUnitPrice!,
                                                condition: sbmitCondition,
                                                description: submitComment,
                                                remarks: submitRemarks!
                                            ) {
                                                appController.addUploadedItem(UploadedItem(
                                                    type: submitType,
                                                    ref: submitRef!,
                                                    colorId: submitColorId,
                                                    qty: submitQty!,
                                                    condition: sbmitCondition,
                                                    comment: submitComment,
                                                    remarks: submitRemarks!,
                                                    unitPrice: submitUnitPrice!,
                                                    inventoryId: inventoryItem.id,
                                                    uploadDate: .now
                                                ))
                                            }
                                            goToNextItem(deleteActiveItem: true)
                                        }
                                    }
                                } label: {
                                    Text("Upload").padding(.horizontal)
                                }
                                .disabled(buttonDisabled)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        
                        AsyncImage(url: appController.imageUrl(forItemType: activeUploadItem.type, ref: editRef, colorId: editColorId))
                            .frame(minHeight: 70, maxHeight: 70, alignment: .top)
                            .frame(minWidth: 90, maxWidth: 90, alignment: .top)
                        
                        Button {
                            goToNextItem(deleteActiveItem: false)
                        } label: {
                            Text("􁉂 Skip")
                        }
                        Button {
                            appController.deleteUploadItem(activeUploadItem)
                        } label: {
                            Text("􀈑 Delete")
                        }
                    }
                }
                
            } else {
                
                Text("Nothing to upload")
            }
            
            Spacer()
        }
        .onAppear {
            Task {
                populateEditValues()
                await self.pullInventory()
            }
        }
        .onChange(of: activeUploadItem) {
            Task {
                populateEditValues()
                await self.pullInventory()
            }
        }
        .onChange(of: editRef) {
            Task {
                await self.pullCatalogEntry()
            }
        }
        .onChange(of: [editRef, editColorId, editCondition, editComment]) {
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
    
    
    func goToNextItem(deleteActiveItem: Bool) {
        
        if let activeUploadItem = activeUploadItem {
            
            let items = appController.uploadItems
            let idx = items.firstIndex(of: activeUploadItem)!
            let nextIndex = items.index(after: idx)
            
            if deleteActiveItem {
            
                appController.deleteUploadItem(activeUploadItem)
            }
            
            if nextIndex < items.endIndex {
                
                let nextItem = items[nextIndex]
                selectedItemId = nextItem.id
            }
        }
    }
    
    
    func populateEditValues() {
        
        if let activeUploadItem = activeUploadItem {
            
            editRef = activeUploadItem.ref
            editColorId = activeUploadItem.colorId
            editQty = activeUploadItem.qty
            editCondition = activeUploadItem.condition
            editComment = activeUploadItem.comment
            editUnitPrice = activeUploadItem.unitPrice
        }
    }
    
    
    func pullInventory() async {
        
        guard let activeUploadItem = activeUploadItem else { return }
        
        await parallel([
            {
                self.inventoryResult = nil
                self.editRemarks = ""
                
                if let item = await appController.getInventory(
                    forItemType: activeUploadItem.type,
                    colorId: editColorId,
                    ref: editRef,
                    condition: editCondition,
                    comment: editComment
                ) {
                    
                    self.inventoryResult = .found(item)
                    self.editRemarks = item.remarks
                } else {
                    self.inventoryResult = .notFound
                }
            },
            {
                self.relatedInventories = nil
                self.relatedInventories = await appController.getInventoriesForAllColors(for: activeUploadItem)
            }
        ])
    }
    
    
    func pullCatalogEntry() async {
        
        guard let activeUploadItem = activeUploadItem else { return }
        
        self.catalogResult = nil
        
        if let catalog = await appController.getCatalogItem(forItemType: activeUploadItem.type, ref: editRef) {
            
            self.catalogResult = .found(catalog)
        } else {
            self.catalogResult = .notFound
        }
    }
}



extension Int? {
    
    
    var normalizedOptional: Int? {
        return (self ?? 0) > 0 ? self : nil
    }
}



extension Float? {
    
    
    var normalizedOptional: Float? {
        return (self ?? 0) > 0 ? self : nil
    }
}



extension String {
    
    
    var normalizedOptional: String? {
        
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed == "" ? nil : trimmed
    }
}
