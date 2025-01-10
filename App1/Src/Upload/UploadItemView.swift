
import SwiftUI



struct UploadItemView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let uploadItem: UploadItem
    
    @State var hover = false
    
    @State var catalogResult: Result<CatalogItem>? = nil
    @State var inventoryResult: Result<InventoryItem>? = nil
    @State var relatedInventories: [InventoryItem]? = nil
    
    @State var editModeRef = false
    
    @State var editRef: String = ""
    @State var editColorId: LegoColor.ID = ""
    @State var editCondition: String = ""
    @State var editComment: String = ""
    @State var editQty: Int?
    @State var editUnitPrice: Float?
    @State var editRemarks: String = ""

    
    var body: some View {
     
        VStack {
            
            HStack(spacing: 48) {
                
                Grid(verticalSpacing: 0) {
                    
                    GridRow(alignment: .top) {
                        
                        AsyncImage(url: appController.imageUrl(forItemType: uploadItem.type, ref: uploadItem.ref, colorId: uploadItem.colorId))
                            .frame(minHeight: 70, maxHeight: 70, alignment: .top)
                            .frame(minWidth: 90, maxWidth: 90, alignment: .top)
                        
                        VStack(alignment: .leading) {
                            
                            ZStack(alignment: .leading) {
                                HStack {
                                    Text(uploadItem.ref)
                                    Button {
                                        editModeRef = true
                                    } label: {
                                        Text("􀈊")
                                    }
                                    .buttonStyle(.plain)
                                }
                                .font(.caption).foregroundStyle(.secondary)
                                .opacity(editModeRef ? 0 : 1)
                                
                                TextField("Ref", text: $editRef)
                                    .frame(maxWidth: 100)
                                    .onSubmit({
                                        editModeRef = false
                                    })
                                    .opacity(editModeRef ? 1 : 0)
                            }
                            
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
                            .font(.title3).frame(width: 300, alignment: .leading)
                            
                            if !uploadItem.comment.isEmpty {
                                Text(uploadItem.comment.htmlUnescape())
                            }
                        }
                    }
                    
                    GridRow {
                        
                        Text(uploadItem.condition == "U" ? "USED" : "NEW").font(.title3).gridColumnAlignment(.center)
                        HStack {
                            appController.color(forLegoColorId: uploadItem.colorId).frame(width: 18, height: 18)
                            Text(appController.colorName(forLegoColorId: uploadItem.colorId))
                        }.gridColumnAlignment(.leading)
                    }
                }
                
                Grid(alignment: .leading, horizontalSpacing: 24) {
                    
                    GridRow {
                        Text("Qty").font(.caption).foregroundStyle(.secondary)
                        Text("PU").font(.caption).foregroundStyle(.secondary)
                    }
                    
                    GridRow(alignment: .bottom) {
                        Text("\(uploadItem.qty)").font(.title2).gridColumnAlignment(.center)
                        if let price = uploadItem.unitPrice {
                            Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).monospacedDigit().font(.title2)
                        }
                    }
                }
                
                Button {
                    appController.deleteUploadItem(uploadItem)
                } label: {
                    Text("􀈑 Delete")
                }
            }
            
            VStack(alignment: .leading) {
                
                HStack(alignment: .top, spacing: 48) {
                    
                    AsyncImage(url: appController.imageUrl(forItemType: uploadItem.type, ref: editRef, colorId: editColorId))
                        .frame(minHeight: 70, maxHeight: 70, alignment: .top)
                        .frame(minWidth: 90, maxWidth: 90, alignment: .top)
                    
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
                        
                        let submitType = uploadItem.type
                        let submitRef = editRef.normalizedOptional
                        let submitColorId = editColorId
                        let sbmitCondition = editCondition
                        let submitComment = editComment
                        let submitQty = editQty.normalizedOptional
                        let submitUnitPrice = editUnitPrice.normalizedOptional
                        let submitRemarks = editRemarks.normalizedOptional
                        
                        
                        Text("ref cannot be empty")
                            .foregroundStyle(.red)
                            .opacity(submitRef == nil ? 1 : 0)
                        
                        
                        GridRow {
                            Text("Comment")
                            TextField("Comment", text: $editComment).gridCellColumns(2)
                        }
                        
                        GridRow {
                            Text("Condition")
                            Picker("Condition", selection: $editCondition) {
                                
                                Text("NEW").tag("N")
                                Text("USED").tag("U")
                            }
                            .labelsHidden()
                            .gridCellColumns(2)
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
                            .gridCellColumns(2)
                        }
                        
                        GridRow {
                            Text("Qty")
                            TextField("Qty", value: $editQty, format: .number)
                                .gridCellColumns(status.inventoryItem == nil ? 2 : 1)
                            
                            if let inventoryItem = status.inventoryItem {
                                HStack {
                                    Text("Current: \(inventoryItem.quantity)")
                                    if let qty = submitQty {
                                        Text("􁉂 \(inventoryItem.quantity + qty)")
                                    }
                                }
                            }
                            
                            Text("must be at least 1")
                                .foregroundStyle(.red)
                                .opacity(submitQty == nil ? 1 : 0)
                        }
                        
                        GridRow {
                            Text("Price")
                            TextField("Price", value: $editUnitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                .gridCellColumns(status.inventoryItem == nil ? 2 : 1)
                            
                            if let inventoryItem = status.inventoryItem {
                                Button {
                                    self.editUnitPrice = inventoryItem.unitPrice
                                } label: {
                                    Text("Keep existing")
                                    Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                }
                            }
                            Text("must not be zero")
                                .foregroundStyle(.red)
                                .opacity(submitUnitPrice == nil ? 1 : 0)
                        }
                        
                        GridRow(alignment: .top) {
                            Text("Remarks")
                            HStack(alignment: .top) {
                                TextField("Remarks", text: $editRemarks, prompt: Text("Required")).frame(maxWidth: 100)
                                
                                if let relatedInventories = self.relatedInventories {
                                    
                                    if relatedInventories.isEmpty {
                                        
                                        Text("no related inventory found").foregroundStyle(.secondary)
                                        
                                    } else {
                                        
                                        let remarks = relatedInventories.map { $0.remarks }
                                            .unique .sorted()
                                        
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), alignment: .leading) {
                                            ForEach(remarks, id: \.self) { rem in
                                                Button {
                                                    self.editRemarks = rem
                                                } label: {
                                                    Text(rem)
                                                }
                                                .fixedSize()
                                            }
                                        }
                                    }
                                    
                                } else {
                                    
                                    Text("Loading related inventories...").foregroundStyle(.secondary)
                                }
                                
                            }.gridCellColumns(2)
                                
                            Text("cannot be empty")
                                .foregroundStyle(.red)
                                .opacity(submitRemarks == nil ? 1 : 0)
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
                                    
                                    Task {
                                        
                                        let inventoryItem = await {
                                            
                                            if let inventoryItem = status.inventoryItem {
                                                
                                                await appController.updateInventory(
                                                    
                                                    id: inventoryItem.id,
                                                    addQuantity: submitQty!,
                                                    unitPrice: submitUnitPrice!,
                                                    remarks: submitRemarks!
                                                )
                                                
                                                return inventoryItem
                                                
                                            } else {
                                                
                                                let inventoryItem = await appController.createInventory(
                                                    
                                                    ref: submitRef!,
                                                    type: submitType,
                                                    colorId: submitColorId,
                                                    quantity: submitQty!,
                                                    unitPrice: submitUnitPrice!,
                                                    condition: sbmitCondition,
                                                    description: submitComment,
                                                    remarks: submitRemarks!
                                                )!
                                                
                                                return inventoryItem
                                            }
                                        }()
                                        
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
                                        
                                        appController.deleteUploadItem(uploadItem)
                                    }
                                    
                                } label: {
                                    Text("􀈧 Confirm").padding(.horizontal)
                                }
                                .disabled(buttonDisabled)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .onChange(of: uploadItem, initial: true) {
                Task {
                    populateEditValues()
                }
            }
            .onChange(of: [editRef, editColorId, editCondition, editComment]) {
                Task {
                    await pullInventory()
                }
            }
            .onChange(of: editRef) {
                Task {
                    await pullCatalogEntry()
                }
            }
            .onChange(of: [editRef, editColorId, editCondition, editComment]) {
                self.updateItem()
            }
            .onChange(of: [editQty]) {
                self.updateItem()
            }
            .onChange(of: [editUnitPrice]) {
                self.updateItem()
            }
            .padding()
        }
        .padding()
        .background(Color(nsColor: hover ? .secondarySystemFill : .tertiarySystemFill))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .tertiarySystemFill))
        )
        .onHover { hover in
            self.hover = hover
        }
    }
    
    
    func populateEditValues() {
        
        editRef = uploadItem.ref
        editColorId = uploadItem.colorId
        editQty = uploadItem.qty
        editCondition = uploadItem.condition
        editComment = uploadItem.comment
        editUnitPrice = uploadItem.unitPrice
    }
    
    
    func updateItem() {
        
        if editRef == uploadItem.ref,
           editColorId == uploadItem.colorId,
           editCondition == uploadItem.condition,
           editComment == uploadItem.comment,
           editQty == uploadItem.qty,
           editUnitPrice == uploadItem.unitPrice
        {
            return
        }
        
        let item = UploadItem(
            
            id: uploadItem.id,
            type: uploadItem.type,
            ref: editRef,
            colorId: editColorId,
            qty: editQty ?? uploadItem.qty,
            condition: editCondition,
            comment: editComment,
            unitPrice: editUnitPrice
        )
        appController.updateUploadItem(item)
    }
    
    
    func pullInventory() async {
        
        await parallel([
            {
                self.inventoryResult = nil
                self.editRemarks = ""
                
                if let item = await appController.getInventory(
                    forItemType: uploadItem.type,
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
                self.relatedInventories = await appController.getInventoriesForAllColors(for: uploadItem)
            }
        ])
    }
    
    
    func pullCatalogEntry() async {
        
        self.catalogResult = nil
        
        if let catalog = await appController.getCatalogItem(forItemType: uploadItem.type, ref: editRef) {
            
            self.catalogResult = .found(catalog)
        } else {
            self.catalogResult = .notFound
        }
    }
}



enum Result<T> {
    
    case notFound
    case found(T)
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

