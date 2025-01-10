
import SwiftUI



struct UploadItemView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let uploadItem: UploadItem
    
    @State var hover = false
    
    @State var catalogResult: Result<CatalogItem>? = nil
    @State var inventoryResult: Result<InventoryItem>? = nil
    @State var relatedInventories: [InventoryItem]? = nil
    
    @State var editModeRef = false
    @State var editModeColor = false
    @State var editModeCondition = false
    @State var editModeComment = false
    @State var editModeQty = false
    @State var editModePrice = false
    
    @State var editRef: String = ""
    @State var editColorId: LegoColor.ID = ""
    @State var editCondition: String?
    @State var editComment: String = ""
    @State var editQty: Int?
    @State var editUnitPrice: Float?
    @State var editRemarks: String = ""

    
    var body: some View {
     
        HStack(alignment: .top) {
            
            HStack(alignment: .top, spacing: 48) {
                
                Grid(verticalSpacing: 0) {
                    
                    GridRow(alignment: .top) {
                        
                        AsyncImage(url: appController.imageUrl(forItemType: uploadItem.type, ref: uploadItem.ref, colorId: uploadItem.colorId))
                            .frame(minHeight: 70, maxHeight: 70, alignment: .top)
                            .frame(minWidth: 90, maxWidth: 90, alignment: .top)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            ZStack(alignment: .leading) {
                                
                                Text(uploadItem.ref)
                                    .onTapGesture {
                                        editModeRef = true
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
                            
                            ZStack(alignment: .leading) {
                                
                                Group {
                                    if !(uploadItem.comment ?? "").isEmpty {
                                        Text((uploadItem.comment ?? "").htmlUnescape())
                                    } else {
                                        Text("no comment").italic().foregroundStyle(.secondary)
                                    }
                                }
                                .onTapGesture {
                                    editModeComment = true
                                }
                                .opacity(editModeComment ? 0 : 1)
                                
                                TextField("Comment", text: $editComment)
                                    .frame(maxWidth: 200)
                                    .onSubmit({
                                        editModeComment = false
                                    })
                                    .opacity(editModeComment ? 1 : 0)
                            }
                        }
                    }
                    
                    GridRow {
                        
                        ZStack {
                            
                            Text(uploadItem.condition != nil ? (uploadItem.condition == "U" ? "USED" : "NEW") : "-").font(.title3)
                                .onTapGesture {
                                    editModeCondition = true
                                }
                            .opacity(editModeCondition ? 0 : 1)
                            
                            Picker("Condition", selection: $editCondition) {
                                
                                Text("NEW").tag("N")
                                Text("USED").tag("U")
                            }
                            .labelsHidden()
                            .frame(maxWidth: 90)
                            .onChange(of: editCondition) {
                                editModeCondition = false
                            }
                            .opacity(editModeCondition ? 1 : 0)
                            
                        }.gridColumnAlignment(.center)
                          
                        HStack {
                            appController.color(forLegoColorId: uploadItem.colorId).frame(width: 18, height: 18)
                            
                            ZStack(alignment: .leading) {
                             
                                Text(appController.colorName(forLegoColorId: uploadItem.colorId))
                                    .onTapGesture {
                                        editModeColor = true
                                    }
                                 .opacity(editModeColor ? 0 : 1)
                                
                                Picker("Color", selection: $editColorId) {
                                    
                                    ForEach(appController.allColors) { color in
                                        
                                        Text(color.name).foregroundStyle(Color(fromBLCode: color.colorCode))
                                            .tag(color.id)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(maxWidth: 150)
                                .onChange(of: editColorId, {
                                    editModeColor = false
                                })
                                .opacity(editModeColor ? 1 : 0)
                            }
                        }
                        .gridColumnAlignment(.leading)
                    }
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Qty")
                            .font(.caption).foregroundStyle(.secondary)
                        
                        ZStack {
                            
                            Group {
                                if let qty = uploadItem.qty {
                                    Text("\(qty)")
                                } else {
                                    Text("-")
                                }
                            }
                            .font(.title2).gridColumnAlignment(.center)
                            .onTapGesture {
                                editModeQty = true
                            }
                            .opacity(editModeQty ? 0 : 1)
                            
                            TextField("Qty", value: $editQty, format: .number)
                                .frame(maxWidth: 50)
                                .onSubmit({
                                    editModeQty = false
                                })
                                .opacity(editModeQty ? 1 : 0)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text("PU")
                        .font(.caption).foregroundStyle(.secondary)
                        
                        ZStack {
                            
                            Group {
                                if let price = uploadItem.unitPrice {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).monospacedDigit()
                                } else {
                                    Text("-")
                                }
                            }
                            .font(.title2)
                            .onTapGesture {
                                editModePrice = true
                            }
                            .opacity(editModePrice ? 0 : 1)
                            
                            TextField("Price", value: $editUnitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                .onSubmit({
                                    editModePrice = false
                                })
                                .frame(maxWidth: 100)
                                .opacity(editModePrice ? 1 : 0)
                        }
                    }
                }
            }

            Divider()
                .padding(.leading, 48)
                .padding(.trailing, 12)
            
            VStack(alignment: .leading) {
                
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
                
                if uploadItem.condition != nil {
                    
                    if status.isLoadingInventory {
                        
                        Text("Checking inventory...").foregroundStyle(.secondary)
                        
                    } else {
                        
                        Group {
                            if let inventoryItem = status.inventoryItem {
                                
                                HStack {
                                    Text("Will update")
                                    Link("#\(inventoryItem.id)", destination: URL(string: "https://www.bricklink.com/v2/inventory_detail.page?invID=\(inventoryItem.id)#/")!)
                                }
                                
                            } else {
                                
                                Text("Will create new inventory")
                            }
                        }
                        .font(.title3)
                    }
                }
                
                let submitType = uploadItem.type
                let submitRef = editRef.normalizedOptional
                let submitColorId = editColorId
                let sbmitCondition = editCondition
                let submitComment = editComment
                let submitQty = editQty.normalizedOptional
                let submitUnitPrice = editUnitPrice.normalizedOptional
                let submitRemarks = editRemarks.normalizedOptional
                
                Text("invalid item ref")
                    .foregroundStyle(.red)
                    .opacity(submitRef == nil ? 1 : 0)
                
                Text("invalid condition")
                    .foregroundStyle(.red)
                    .opacity(sbmitCondition == nil ? 1 : 0)
                
                Text("qty must be at least 1")
                    .foregroundStyle(.red)
                    .opacity(submitQty == nil ? 1 : 0)
                
                Text("price cannot be zero")
                    .foregroundStyle(.red)
                    .opacity(submitUnitPrice == nil ? 1 : 0)
                    
                Grid(alignment: .leading) {
                    
                    if let inventoryItem = status.inventoryItem {
                        HStack {
                            Text("Current qty: \(inventoryItem.quantity)")
                            if let qty = submitQty {
                                Text("􁉂 \(inventoryItem.quantity + qty)")
                            }
                        }
                    }
                    
                    if let inventoryItem = status.inventoryItem {
                        Button {
                            self.editUnitPrice = inventoryItem.unitPrice
                        } label: {
                            Text("Keep existing")
                            Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                        }
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
                    
                    GridRow {
                        
                        Color.clear.frame(width: 2, height: 2)
                        
                        HStack {
                            
                            let buttonDisabled = status.isLoadingInventory
                            || submitRef == nil
                            || sbmitCondition == nil
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
                                                condition: sbmitCondition!,
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
                                        condition: sbmitCondition!,
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
                            
                            Color.clear.frame(width: 12)
                            
                            Button {
                                appController.deleteUploadItem(uploadItem)
                            } label: {
                                Text("􀈑 Delete")
                            }
                        }
                    }
                }
            }
            
            .onChange(of: uploadItem, initial: true) {
                
                populateEditValues()
            }
            
            .onChange(of: editModeRef, updateItemOnExitEditMode)
            .onChange(of: editModeColor, updateItemOnExitEditMode)
            .onChange(of: editModeCondition, updateItemOnExitEditMode)
            .onChange(of: editModeComment, updateItemOnExitEditMode)
            .onChange(of: editModeQty, updateItemOnExitEditMode)
            .onChange(of: editModePrice, updateItemOnExitEditMode)
            
            .onChange(of: uploadItem.ref, initial: true) {
                Task {
                    await pullCatalogEntry()
                }
            }
            
            .onChange(of: [uploadItem.ref, uploadItem.colorId, uploadItem.condition, uploadItem.comment], initial: true) {
                Task {
                    await pullInventory()
                }
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
    
    
    func updateItemOnExitEditMode(old: Bool, new: Bool) {
        
        if new == false {
            updateItem()
        }
    }
    
    
    func populateEditValues() {
        
        editRef = uploadItem.ref
        editColorId = uploadItem.colorId
        editQty = uploadItem.qty
        editCondition = uploadItem.condition
        editComment = uploadItem.comment ?? ""
        editUnitPrice = uploadItem.unitPrice
    }
    
    
    func updateItem() {
        
        if editRef == uploadItem.ref,
           editColorId == uploadItem.colorId,
           editCondition == uploadItem.condition,
           editComment.trimmingCharacters(in: .whitespacesAndNewlines) == (uploadItem.comment ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
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
            qty: editQty,
            condition: editCondition,
            comment: editComment,
            unitPrice: editUnitPrice
        )
        appController.updateUploadItem(item)
    }
    
    
    func pullInventory() async {
        
        guard uploadItem.condition != nil else { return }
        
        await parallel([
            {
                self.inventoryResult = nil
                self.editRemarks = ""
                
                if let item = await appController.getInventory(for: uploadItem) {
                    
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

