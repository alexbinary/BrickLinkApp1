
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
                                    validatedValue_type.isInvalid ? .red
                                    : validatedValue_type.hasChanges ? .blue
                                    : .secondary
                                )
                                
                            ItemTypePicker("Type", selection: $editingValue_type)
                                .labelsHidden()
                                
                            Button("􀅉") { editingValue_type = savedValue_type }
                                .opacity(validatedValue_type.hasChanges ? 1 : 0)
                        }
                        
                        GridRow {
                            
                            Text("Ref")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(
                                    validatedValue_ref.isInvalid ? .red
                                    : validatedValue_ref.hasChanges ? .blue
                                    : .secondary
                                )
                                
                            TextField("Ref", text: $editingValue_ref)
                                .onSubmit({
                                    if editingValue_ref.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                                        editingValue_ref = uploadItem.ref
                                    }
                                })
                            
                            Button("􀅉") { editingValue_ref = savedValue_ref }
                                .opacity(validatedValue_ref.hasChanges ? 1 : 0)
                        }
                        
                        GridRow {
                            
                            Text("Name")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(
                                    validatedValue_name.isInvalid ? .red
                                    : validatedValue_name.hasChanges ? .blue
                                    : .secondary
                                )
                            
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
                            
                            Button("􀅉") { Task { await refreshCatalogEntry() } }
                        }
                        
                        GridRow {
                            
                            Text("Color")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(
                                    validatedValue_colorId.isInvalid ? .red
                                    : validatedValue_colorId.hasChanges ? .blue
                                    : .secondary
                                )
                            
                            LegoColorPicker("Color", selection: $editingValue_colorId)
                                .labelsHidden()
                                .onChange(of: editingValue_colorId, {
                                    
                                })
                            
                            Button("􀅉") { editingValue_colorId = savedValue_colorId }
                                .opacity(validatedValue_colorId.hasChanges ? 1 : 0)
                        }
                        
                        GridRow {
                            
                            Text("Condition")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(
                                    validatedValue_condition.isInvalid ? .red
                                    : validatedValue_condition.hasChanges ? .blue
                                    : .secondary
                                )
                            
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
                                
                            }
                            
                            Button("􀅉") { editingValue_condition = savedValue_condition }
                                .opacity(validatedValue_condition.hasChanges ? 1 : 0)
                        }
                        
                        GridRow {
                            
                            Text("Comment")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(
                                    validatedValue_comment.isInvalid ? .red
                                    : validatedValue_comment.hasChanges ? .blue
                                    : .secondary
                                )
                            
                            TextField("Comment", text: $editingValue_comment)
                                .onSubmit {
                                    
                                }
                            
                            Button("􀅉") { editingValue_comment = savedValue_comment }
                                .opacity(validatedValue_comment.hasChanges ? 1 : 0)
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
                
                if itemIsValid {
                    
                    Group {
                        
                        if let inventoryItem = inventoryItem {
                            HStack {
                                Text("Updating lot")
                                InventoryLink(inventoryItem) { Text("\(inventoryItem.id)") }
                            }
                        } else {
                            Text("This is a new lot 􀫸")
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
                            
                            Text("Quantity")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(
                                    validatedValue_quantity.isInvalid ? .red
                                    : validatedValue_quantity.hasChanges ? .blue
                                    : .secondary
                                )
                            
                            HStack {
                                TextField("Qty", value: $editingValue_quantity, format: .number)
                                    .onSubmit({
                                        
                                    })
                                
                                Button {
                                    editingValue_quantity = (editingValue_quantity ?? 0) + 1
                                } label: {
                                    Text("􀅼")
                                }
                                
                                Button {
                                    editingValue_quantity = (editingValue_quantity ?? 0) - 1
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
                            
                            Button("􀅉") { editingValue_quantity = savedValue_quantity }
                                .opacity(validatedValue_quantity.hasChanges ? 1 : 0)
                        }
                        
                        GridRow {
                            
                            Text("Unit price")
                                .gridColumnAlignment(.trailing)
                                .foregroundStyle(
                                    validatedValue_unitPrice.isInvalid ? .red
                                    : validatedValue_unitPrice.hasChanges ? .blue
                                    : .secondary
                                )
                            
                            TextField("Price", value: $editingValue_unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                .onSubmit({
                                    
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
                                
                                Button("keep existing") {
                                    editingValue_unitPrice = inventoryItem.unitPrice
                                }
                            }
                            
                            Button("􀅉") { editingValue_unitPrice = savedValue_unitPrice }
                                .opacity(validatedValue_unitPrice.hasChanges ? 1 : 0)
                        }
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
                    
                    if validatedValue_location.isInvalid {
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
                
                let newLocation = validatedValue_location.submitValue
                
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
                Task { await refreshCatalogEntry() }
            }
        }
        .onChange(of: validatedValue_type.submitValue, initial: true) {
            
            Task { await refreshCatalogEntry() }
        }
        .onChange(of: validatedValue_ref.submitValue, initial: true) {
            
            Task { await refreshCatalogEntry() }
        }
        
        //
        
        .onChange(of: inventoryItem, initial: true) {
            
            self.editingValue_remarks = inventoryItem?.remarks ?? ""
        }
    }
    
    
    var validatedValue_type: ValidatedValue<ItemType> {
        
        .init(
            submitValue: editingValue_type, isInvalid: false,
            hasChanges: editingValue_type != savedValue_type
        )
    }
    
    var validatedValue_ref: ValidatedValue<String> {
        
        switch catalogResult {
            
        case .found(let entry): .init(
            
            submitValue: entry.ref, isInvalid: false,
            hasChanges: entry.ref != savedValue_ref
        )
        default: .init(
            
            submitValue: nil, isInvalid: true,
            hasChanges: editingValue_ref != savedValue_ref
        )
        }
    }
    
    var validatedValue_name: ValidatedValue<String> {
        
        switch catalogResult {
            
        case .found(let entry): .init(
            
            submitValue: entry.name, isInvalid: false,
            hasChanges: entry.name != savedValue_name
        )
        default: .init(
            
            submitValue: nil, isInvalid: true,
            hasChanges: false
        )
        }
    }
    
    var validatedValue_colorId: ValidatedValue<LegoColor.ID> {
        
        let trimmed = editingValue_colorId.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            
            return .init(
                submitValue: trimmed, isInvalid: false,
                hasChanges: trimmed != savedValue_colorId
            )
            
        } else {
            
            return .init(
                submitValue: nil, isInvalid: true,
                hasChanges: trimmed != savedValue_colorId
            )
        }
    }
    
    var validatedValue_condition: ValidatedValue<ItemCondition> {
        
        if let condition = editingValue_condition {
            
            return .init(
                submitValue: condition, isInvalid: false,
                hasChanges: condition != savedValue_condition
            )
            
        } else {
            
            return .init(
                submitValue: nil, isInvalid: true,
                hasChanges: editingValue_condition != savedValue_condition
            )
        }
    }
    
    var validatedValue_comment: ValidatedValue<String> {
        
        .init(
            submitValue: editingValue_comment, isInvalid: false,
            hasChanges: editingValue_comment != savedValue_comment
        )
    }
    
    var validatedValue_quantity: ValidatedValue<Int> {
        
        if let qty = editingValue_quantity, qty > 0 {
        
            return .init(
                submitValue: qty, isInvalid: false,
                hasChanges: qty != savedValue_quantity
            )
            
        } else {
            
            return .init(
                submitValue: nil, isInvalid: true,
                hasChanges: editingValue_quantity != savedValue_quantity
            )
        }
    }
    
    var validatedValue_unitPrice: ValidatedValue<Float> {
        
        if let price = editingValue_unitPrice, price > 0 {
        
            return .init(
                submitValue: editingValue_unitPrice, isInvalid: false,
                hasChanges: price != savedValue_unitPrice
            )
            
        } else {
            
            return .init(
                submitValue: nil, isInvalid: true,
                hasChanges: editingValue_unitPrice != savedValue_unitPrice
            )
        }
    }
    
    var validatedValue_location: ValidatedValue<Location> {
        
        if let loc = Location(from: editingValue_remarks) {
            
            .init(
                submitValue: loc, isInvalid: false,
                hasChanges: loc.textRepresentation != inventoryItem?.remarks
            )
            
        } else {
            
            .init(
                submitValue: nil, isInvalid: true,
                hasChanges: editingValue_remarks != inventoryItem?.remarks
            )
        }
    }
    
    
    func refreshCatalogEntry() async {
        
        guard let type = validatedValue_type.submitValue,
              let ref = validatedValue_ref.submitValue
        else {
            return
        }
        
        self.catalogResult = .loading
        
        if let catalogEntry = await catalog.fetchEntry(forItemType: type, ref: ref) {
            
            self.catalogResult = .found(catalogEntry)
        } else {
            self.catalogResult = .notFound
        }
    }
    
    
    var itemIsValid: Bool {
        
        return
            validatedValue_type.submitValue != nil
            &&
            validatedValue_ref.submitValue != nil
            &&
            validatedValue_colorId.submitValue != nil
            &&
            validatedValue_condition.submitValue != nil
    }
    
    
    var inventoryItem: InventoryItem? {
        
        if let type = validatedValue_type.submitValue,
           let ref = validatedValue_ref.submitValue,
           let colorId = validatedValue_colorId.submitValue,
           let condition = validatedValue_condition.submitValue {
            
            let comment = validatedValue_comment.submitValue
            
            return inventoryStore.inventory(
                
                forItemType: type,
                ref: ref,
                comment: comment,
                colorId: colorId,
                condition: condition
            )
        } else {
            return nil
        }
    }
    
    
    var suggestedLocations: [String] {
        
        if let type = validatedValue_type.submitValue,
           let ref = validatedValue_ref.submitValue,
           let condition = validatedValue_condition.submitValue {
            
            let comment = validatedValue_comment.submitValue
            
            return uploadStore.suggestedLocations(
                
                forItemType: type,
                ref: ref,
                comment: comment,
                condition: condition
            )
        } else {
            return []
        }
    }
    
    
    var savedValue_type: ItemType { uploadItem.type }
    var savedValue_ref: String { uploadItem.ref }
    var savedValue_name: String? { uploadItem.name }
    var savedValue_colorId: LegoColor.ID { uploadItem.colorId }
    var savedValue_condition: ItemCondition? { uploadItem.condition }
    var savedValue_comment: String { uploadItem.comment ?? "" }
    var savedValue_quantity: Int? { uploadItem.qty }
    var savedValue_unitPrice: Float? { uploadItem.unitPrice }
    
    
    var hasChanges: Bool {
        
        validatedValue_type.hasChanges
        ||
        validatedValue_ref.hasChanges
        ||
        validatedValue_colorId.hasChanges
        ||
        validatedValue_condition.hasChanges
        ||
        validatedValue_comment.hasChanges
        ||
        validatedValue_quantity.hasChanges
        ||
        validatedValue_unitPrice.hasChanges
    }
    
    
    var canSaveChanges: Bool {
        
        validatedValue_type.isValid
        &&
        validatedValue_ref.isValid
        &&
        validatedValue_colorId.isValid
        &&
        validatedValue_condition.isValid
        &&
        validatedValue_comment.isValid
        &&
        validatedValue_quantity.isValid
        &&
        validatedValue_unitPrice.isValid
    }
    
    
    func saveChanges() {
        
        uploadStore.update(UploadItem(
            
            id: uploadItem.id,
            type: validatedValue_type.submitValue!,
            ref: validatedValue_ref.submitValue!,
            name: validatedValue_name.submitValue!,
            colorId: validatedValue_colorId.submitValue!,
            qty: validatedValue_quantity.submitValue!,
            condition: validatedValue_condition.submitValue!,
            comment: validatedValue_comment.submitValue!,
            unitPrice: validatedValue_unitPrice.submitValue!
        ))
    }
    
    
    func deleteUploadItem() {
        
        uploadStore.delete(uploadItem)
    }
    
    
    var canUpload: Bool {
        
        if isSubmitting { return false }
        
        return
            validatedValue_type.isValid
            &&
            validatedValue_ref.isValid
            &&
            validatedValue_colorId.isValid
            &&
            validatedValue_condition.isValid
            &&
            validatedValue_comment.isValid
            &&
            validatedValue_quantity.isValid
            &&
            validatedValue_unitPrice.isValid
            &&
            validatedValue_location.isValid
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
            addQuantity: validatedValue_quantity.submitValue!,
            unitPrice: validatedValue_unitPrice.submitValue!,
            remarks: validatedValue_location.submitValue!.textRepresentation
        )
    }
    
    
    func createInventory() async -> InventoryItem {
        
        await inventoryStore.createInventory(
            
            ref: validatedValue_ref.submitValue!,
            type: validatedValue_type.submitValue!,
            colorId: validatedValue_colorId.submitValue!,
            quantity: validatedValue_quantity.submitValue!,
            unitPrice: validatedValue_unitPrice.submitValue!,
            condition: validatedValue_condition.submitValue!,
            description: validatedValue_comment.submitValue!,
            remarks: validatedValue_location.submitValue!.textRepresentation
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
            type: validatedValue_type.submitValue!,
            ref: validatedValue_ref.submitValue!,
            name: validatedValue_name.submitValue!,
            colorId: validatedValue_colorId.submitValue!,
            qtyBefore: qtyBefore,
            qtyAfter:  (qtyBefore ?? 0) + validatedValue_quantity.submitValue!,
            condition: validatedValue_condition.submitValue!,
            comment: validatedValue_comment.submitValue!,
            remarksBefore: remarksBefore,
            remarksAfter: validatedValue_location.submitValue!.textRepresentation,
            unitPriceBefore: priceBefore,
            unitPriceAfter: validatedValue_unitPrice.submitValue!,
            inventoryId: inventoryId,
            uploadDate: .now,
            inventoryStatus: inventoryStatus
        ))
    }
}
