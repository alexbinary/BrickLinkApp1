
import SwiftUI



struct UploadActiveItemView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let uploadItemId: UploadItem.ID
    var uploadItem: UploadItem { uploadStore.uploadItemsForList.first(where: { $0.id == uploadItemId })! }
    
    
    @State var editingValue_type: ItemType = .part
    @State var editingValue_ref: String = ""
    @State var editingValue_colorId: LegoColor.ID = ""
    @State var editingValue_condition: ItemCondition?
    @State var editingValue_comment: String = ""
    @State var editingValue_quantity: Int?
    @State var editingValue_unitPrice: Float?
    @State var editingValue_remarks: String = ""
    
    @State var catalogResult: Result<CatalogEntry>? = nil
    @State var isSubmitting = false

    
    var body: some View {
        
        let itemErrors: [String] = {
            
            var errors = [String]()
            
            if uploadItem.ref.normalizedOptional == nil {
                errors.append("invalid item ref")
            }
            
            if uploadItem.condition == nil {
                errors.append("missing condition")
            }
            
            return errors
        }()
        
        let itemValid = itemErrors.isEmpty
        
        HStack(alignment: .top) {
            
            VStack(alignment: .leading) {
                
                Text("Upload item 􁉂").font(.title2)
                    .padding(.bottom)
                
                HStack(alignment: .top, spacing: 16) {
                    
                    Grid(alignment: .leading) {
                        
                        GridRow {
                            
                            Text("Type")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(
                                    editingValue_type != savedValue_type ? .blue
                                    : .secondary
                                )
                                
                            ItemTypePicker("Type", selection: $editingValue_type)
                                .labelsHidden()
                                
                            Button("􀅉") { editingValue_type = savedValue_type }
                        }
                        
                        GridRow {
                            
                            Text("Ref")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(
                                    editingValue_ref != savedValue_ref ? .blue
                                    : .secondary
                                )
                                
                            TextField("Ref", text: $editingValue_ref)
                                .onSubmit({
                                    if editingValue_ref.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                                        editingValue_ref = uploadItem.ref
                                    }
                                    updateItem(ref: ChangeValue(to: editingValue_ref))
                                })
                        }
                        
                        GridRow {
                            
                            Text("Name").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                            
                            Group {
                                
                                if let catalogResult = catalogResult {
                                    
                                    switch catalogResult {
                                        
                                    case .loading:
                                        HStack {
                                            Text("Fetching catalog entry...")
                                            ProgressView().controlSize(.mini)
                                        }
                                        .foregroundStyle(.secondary)
                                        
                                    case .notFound:
                                        Text("invalid type/ref")
                                        .foregroundStyle(.red)
                                    
                                    case .found(let catalogEntry):
                                        Text(catalogEntry.name)
                                            .lineLimit(nil)
                                            .font(.title3)
                                    }
                                    
                                } else if let name = uploadItem.name {
                                    
                                    Text(name)
                                        .lineLimit(nil)
                                        .font(.title3)
                                    
                                } else {
                                    
                                    Text("-")
                                }
                            }
                        }
                        
                        GridRow {
                            
                            Text("Color").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                            
                            LegoColorPicker("Color", selection: $editingValue_colorId)
                                .labelsHidden()
                                .onChange(of: editingValue_colorId, {
                                    updateItem(colorId: ChangeValue(to: editingValue_colorId))
                                })
                        }
                        
                        GridRow {
                            
                            Text("Condition").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                            
                            Picker("Condition", selection: $editingValue_condition) {
                                
                                Text("").tag(nil as ItemCondition?)
                                Text("NEW")
                                    .foregroundStyle(ItemCondition.new.color)
                                    .fontWeight(.bold)
                                    .tag(ItemCondition.new)
                                Text("USED")
                                    .foregroundStyle(ItemCondition.used.color)
                                    .fontWeight(.bold)
                                    .tag(ItemCondition.used)
                            }
                            .labelsHidden()
                            .onChange(of: editingValue_condition) {
                                updateItem(condition: ChangeValue(to: editingValue_condition))
                            }
                        }
                        
                        GridRow {
                            
                            Text("Comment").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                            
                            TextField("Comment", text: $editingValue_comment)
                                .onSubmit {
                                    updateItem(comment: ChangeValue(to: editingValue_comment))
                                }
                        }
                    }
                    
                    VStack {
                        CatalogImage(
                            itemType: editingValue_type,
                            ref: editingValue_ref,
                            colorId: editingValue_colorId,
                            scale: 2
                        )
                        .border(uploadItem.condition?.color ?? .black, width: 2)
                        
                        if let condition = uploadItem.condition {
                            Text(condition.name.uppercased())
                                .font(.title3)
                                .foregroundStyle(condition.color)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                Group {
                    if itemValid {
                        if let inventoryItem = inventoryItem {
                            HStack {
                                Text("Updating lot")
                                InventoryLink(inventoryItem) { Text("\(inventoryItem.id)") }
                            }
                        } else {
                            Text("This is a new lot 􀫸")
                        }
                    }
                }
                .font(.title3)
                .padding(.vertical)
                
                Grid(alignment: .leading, verticalSpacing: 6) {
                    
                    if inventoryItem != nil {
                        GridRow {
                            Text("")
                            Text("")
                            Text("Current")
                            Text("Updated")
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    GridRow {
                        
                        Text("Quantity").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                        
                        HStack {
                            TextField("Qty", value: $editingValue_quantity, format: .number)
                                .onSubmit({
                                    updateItem(qty: ChangeValue(to: editingValue_quantity))
                                })
                            
                            Button {
                                updateItem(qty: ChangeValue(to: (uploadItem.qty ?? 0) + 1))
                            } label: {
                                Text("􀅼")
                            }
                            
                            Button {
                                updateItem(qty: ChangeValue(to: (uploadItem.qty ?? 0) - 1))
                            } label: {
                                Text("􀅽")
                            }
                        }
                        
                        if let inventoryItem = inventoryItem {
                            
                            Text("\(inventoryItem.quantity)").gridColumnAlignment(.center).font(.title3)
                            
                            if let qty = uploadItem.qty {
                                Text("􁉂 \(inventoryItem.quantity + qty)").gridColumnAlignment(.center).font(.title3)
                            } else {
                                Text("")
                            }
                        }
                    }
                    
                    GridRow {
                        
                        Text("Unit price").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                        
                        TextField("Price", value: $editingValue_unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                            .onSubmit({
                                updateItem(unitPrice: ChangeValue(to: editingValue_unitPrice))
                            })
                        
                        if let inventoryItem = inventoryItem {
                            
                            Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).font(.title3)
                            
                            if let price = uploadItem.unitPrice {
                                if price != inventoryItem.unitPrice {
                                    HStack {
                                        Text("􁉂")
                                        Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).font(.title3)
                                    }
                                } else {
                                    Text("unchanged")
                                }
                            } else {
                                Text("")
                            }
                            
                            Button("􀅉") {
                                editingValue_unitPrice = inventoryItem.unitPrice
                            }
                        }
                    }
                    
                    Color.clear.frame(width: 0, height: 12)
                    
                    GridRow {
                        
                        Color.clear.frame(width: 0)
                        
                        HStack(spacing: 12) {
                            
                            let submitErrors = {
                                
                                var errors = [String]()
                                
                                if submitValue_quantity == nil {
                                    errors.append("missing valid qty")
                                }
                                
                                if submitValue_unitPrice == nil {
                                    errors.append("missing valid price")
                                }
                                
                                if submitValue_remarks == nil {
                                    errors.append("missing valid remarks")
                                }
                                
                                return errors
                            }()
                            
                            Text((submitErrors+itemErrors).joined(separator: ", ")).italic().fixedSize()
                        }
                        .gridCellColumns(3)
                    }
                }
            }
            .padding()
            
            VStack(alignment: .leading) {
                
                Text("Location 􁉂􀈫").font(.title2)
                    .padding(.bottom)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    HStack {
                        
                        TextField("Location", text: $editingValue_remarks)
                            .frame(width: 100)
                        
                        if let inventoryItem = inventoryItem {
                            Button("􀅉") { editingValue_remarks = inventoryItem.remarks }
                        }
                        
                        Color.clear.frame(width: 16, height: 0)
                        
                        if !suggestedLocations.isEmpty {
                            
                            Text("suggested: ").italic().foregroundStyle(.secondary)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(suggestedLocations, id: \.self) { location in
                                        Button {
                                            self.editingValue_remarks = location
                                        } label: {
                                            Text(location)
                                        }
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }
                }
                
                HStack {
                    
                    Button {
                        Task { await upload() }
                    } label: {
                        Text("􀈧 Upload").padding(.horizontal)
                    }
                    .disabled(!canUpload)
                    
                    if validatedLocation.hasWarning {
                        Text("invalid location").italic().fixedSize()
                    }
                    
                    if isSubmitting {
                        ProgressView().controlSize(.small)
                    }
                    
                    Spacer()
                    
                    Button {
                        saveChanges()
                    } label: {
                        Text("􀈽 Save changes")
                    }
                    .disabled(!hasChanges || !canSaveChanges)
                    
                    Button {
                        deleteUploadItem()
                    } label: {
                        Text("􀈑 Delete")
                    }
                }
                
                Divider().padding(.top)
                
                let newLocation = validatedLocation.valueToSubmit
                
                InventoryTargetLocationView(newLocation: newLocation, candidateItems: [uploadItem], columnsCount: 6)
                    .padding(.vertical)
            }
            .padding()
        }
        
        // init edit values
        
        .onChange(of: uploadItem.type, initial: true) {
            
            editingValue_type = uploadItem.type
        }
        .onChange(of: uploadItem.ref, initial: true) {
            
            editingValue_ref = uploadItem.ref
        }
        .onChange(of: uploadItem.colorId, initial: true) {
            
            editingValue_colorId = uploadItem.colorId
        }
        .onChange(of: uploadItem.condition, initial: true) {
            
            editingValue_condition = uploadItem.condition
        }
        .onChange(of: uploadItem.comment, initial: true) {
            
            editingValue_comment = uploadItem.comment ?? ""
        }
        .onChange(of: uploadItem.qty, initial: true) {
            
            editingValue_quantity = uploadItem.qty
        }
        .onChange(of: uploadItem.unitPrice, initial: true) {
            
            editingValue_unitPrice = uploadItem.unitPrice
        }
        
        // update catalog entry
        
        .onChange(of: uploadItem.name, initial: true) { old, new in
            if new == nil {
                Task { await pullCatalogEntry(type: savedValue_type, ref: savedValue_ref) }
            }
        }
        .onChange(of: editingValue_ref, initial: true) {
            
            Task { await pullCatalogEntry(type: savedValue_type, ref: editingValue_ref) }
        }
        .onChange(of: uploadItem.ref, initial: false) {
            
            switch catalogResult {
            case .found(let entry):
                updateItem(name: ChangeValue(to: entry.name))
            default:
                break
            }
        }
        
        //
        
        .onChange(of: [uploadItem.ref, uploadItem.colorId, uploadItem.comment], initial: true) {
            self.editingValue_remarks = self.inventoryItem?.remarks ?? ""
        }
        .onChange(of: [uploadItem.condition], initial: true) {
            self.editingValue_remarks = self.inventoryItem?.remarks ?? ""
        }
    }
    
    
    func pullCatalogEntry(type: ItemType, ref: String) async {
        
        self.catalogResult = .loading
        
        if let catalogEntry = await catalog.fetchEntry(forItemType: type, ref: ref) {
            
            self.catalogResult = .found(catalogEntry)
            updateItem(name: ChangeValue(to: catalogEntry.name))
        } else {
            self.catalogResult = .notFound
        }
    }
    
    
    var inventoryItem: InventoryItem? {
        
        if let condition = editingValue_condition {
            
            return inventoryStore.inventory(
                
                forType: editingValue_type,
                ref: editingValue_ref,
                comment: editingValue_comment,
                colorId: editingValue_colorId,
                condition: condition
            )
        }
        return nil
    }
    
    
    var suggestedLocations: [String] {
        
        if let condition = editingValue_condition {
            
            return uploadStore.suggestedLocations(
                
                forItemType: editingValue_type,
                ref: editingValue_ref,
                comment: editingValue_comment,
                condition: condition
            )
        }
        
        return []
    }
    
    
    var savedValue_type: ItemType { uploadItem.type }
    var savedValue_ref: String { uploadItem.ref }
    var savedValue_name: String? { uploadItem.name }
    var savedValue_colorId: LegoColor.ID { uploadItem.colorId }
    var savedValue_condition: ItemCondition? { uploadItem.condition }
    var savedValue_comment: String? { uploadItem.comment }
    var savedValue_quantity: Int? { uploadItem.qty }
    var savedValue_unitPrice: Float? { uploadItem.unitPrice }
    
    
    var validatedValue_type: ValidatedValue<ItemType> {
        
        .init(valueToSubmit: editingValue_type)
    }
    
    var submitValue_ref: String? {
        switch catalogResult {
        case .found(let entry): entry.ref
        default: nil
        }
    }
    
    var submitValue_name: String? { uploadItem.name }
    
    var submitValue_colorId: LegoColor.ID { uploadItem.colorId }
    
    var submitValue_condition: ItemCondition? { uploadItem.condition }
    
    var submitValue_comment: String? { uploadItem.comment }
    
    var submitValue_quantity: Int? { uploadItem.qty.normalizedOptional }
    
    var submitValue_unitPrice: Float? { uploadItem.unitPrice.normalizedOptional }
    
    var submitValue_remarks: String? { editingValue_remarks.normalizedOptional }
    
    
    var validatedLocation: ValidatedValue<Location> {
        
        if let loc = Location(from: editingValue_remarks) {
            .init(valueToSubmit: loc, hasWarning: false)
        } else if editingValue_remarks.isEmpty {
            .init(valueToSubmit: nil, hasWarning: false)
        } else {
            .init(valueToSubmit: nil, hasWarning: true)
        }
    }
    
    
    var hasChanges: Bool {
        
        editingValue_type != savedValue_type
        ||
        editingValue_ref != savedValue_ref
    }
    
    
    var canSaveChanges: Bool {
        
        validatedValue_type.valueToSubmit != nil
        &&
        submitValue_ref != nil
    }
    
    
    func saveChanges() {
        
        uploadStore.update(UploadItem(
            
            id: uploadItem.id,
            type: validatedValue_type.valueToSubmit!,
            ref: submitValue_ref!,
            name: submitValue_name,
            colorId: submitValue_colorId,
            qty: submitValue_quantity,
            condition: submitValue_condition,
            comment: submitValue_comment,
            unitPrice: submitValue_unitPrice
        ))
    }
    
    
    func deleteUploadItem() {
        
        uploadStore.delete(uploadItem)
    }
    
    
    var canUpload: Bool {
        
        return !(isSubmitting
        || submitValue_ref == nil
        || submitValue_condition == nil
        || submitValue_quantity == nil
        || submitValue_unitPrice == nil
        || submitValue_remarks == nil)
    }
    
    
    func upload() async {
        
        isSubmitting = true
        
        let updatedOrCreatedInventoryItem = await createOrUpdateInventory()
        addUploadedItem(inventoryId: updatedOrCreatedInventoryItem.id)
        deleteUploadItem()
        
        isSubmitting = false
    }
    
    
    func updateInventory(id: InventoryItem.ID) async {
        
        await inventoryStore.updateInventory(
            
            inventoryId: id,
            addQuantity: submitValue_quantity!,
            unitPrice: submitValue_unitPrice!,
            remarks: submitValue_remarks!
        )
    }
    
    
    func createInventory() async -> InventoryItem {
        
        await inventoryStore.createInventory(
            
            ref: submitValue_ref!,
            type: validatedValue_type.valueToSubmit!,
            colorId: submitValue_colorId,
            quantity: submitValue_quantity!,
            unitPrice: submitValue_unitPrice!,
            condition: submitValue_condition!,
            description: submitValue_comment,
            remarks: submitValue_remarks!
        )!
    }
    
    
    func createOrUpdateInventory() async -> InventoryItem {
        
        if let inventoryItem = inventoryItem {
            await updateInventory(id: inventoryItem.id)
            return inventoryItem
        } else {
            return await createInventory()
        }
    }
    
    
    func addUploadedItem(inventoryId: InventoryItem.ID) {
        
        let qtyBefore = inventoryItem?.quantity
        let priceBefore = inventoryItem?.unitPrice
        let remarksBefore = inventoryItem?.remarks
        let inventoryStatus = inventoryItem != nil ? UploadInventoryStatus.updated : .created
        
        uploadStore.add(UploadedItem(
            type: validatedValue_type.valueToSubmit!,
            ref: submitValue_ref!,
            name: submitValue_name,
            colorId: submitValue_colorId,
            qtyBefore: qtyBefore,
            qtyAfter:  (qtyBefore ?? 0) + submitValue_quantity!,
            condition: submitValue_condition!,
            comment: submitValue_comment,
            remarksBefore: remarksBefore,
            remarksAfter: submitValue_remarks!,
            unitPriceBefore: priceBefore,
            unitPriceAfter: submitValue_unitPrice!,
            inventoryId: inventoryId,
            uploadDate: .now,
            inventoryStatus: inventoryStatus
        ))
    }
    
    
    func updateItem(
        
        type changeType: ChangeValue<ItemType>? = nil,
        ref changeRef: ChangeValue<String>? = nil,
        name changeName: ChangeValue<String?>? = nil,
        colorId changeColorId: ChangeValue<String>? = nil,
        qty changeQty: ChangeValue<Int?>? = nil,
        condition changeCondition: ChangeValue<ItemCondition?>? = nil,
        comment changeComment: ChangeValue<String?>? = nil,
        unitPrice changeUnitPrice: ChangeValue<Float?>? = nil
    ) {
        uploadStore.update(UploadItem(
            
            id: uploadItem.id,
            type: value(from: changeType, ifNoChange: uploadItem.type),
            ref: value(from: changeRef, ifNoChange: uploadItem.ref),
            name: value(from: changeName, ifNoChange: uploadItem.name),
            colorId: value(from: changeColorId, ifNoChange: uploadItem.colorId),
            qty: value(from: changeQty, ifNoChange: uploadItem.qty),
            condition: value(from: changeCondition, ifNoChange: uploadItem.condition),
            comment: value(from: changeComment, ifNoChange: uploadItem.comment),
            unitPrice: value(from: changeUnitPrice, ifNoChange: uploadItem.unitPrice)
        ))
    }
}



struct ChangeValue<T> {
    
    let newValue: T
    
    init(to newValue: T) {
        self.newValue = newValue
    }
}


func value<T>(from change: ChangeValue<T>?, ifNoChange defaultValue: T) -> T {
    
    change != nil ? change!.newValue : defaultValue
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

extension String? {
    
    var normalizedOptional: String? { (self ?? "").normalizedOptional }
}
