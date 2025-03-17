
import SwiftUI


class AppController: ObservableObject {
    
    
    private let dataStore: DataStore = {
        
        let path = FileManager.default.currentDirectoryPath.appending("/data/data.json5")
        return DataStore(dataFileUrl: URL(fileURLWithPath: path))
    }()
    
    private let blCredentials = Secrets.brickLinkAPICredentials
    
    let orderStore: OrderStore
    let shippingStore: ShippingStore
    
    
    init() {
        
        orderStore = OrderStore(dataStore: dataStore, blCredentials: blCredentials)
        shippingStore = ShippingStore(dataStore: dataStore)
        
        Task {
            await parallel([
                { await self.loadColors() },
                { await self.loadInventories() },
                { await self.loadOrderSummaries() },
            ])
        }
    }
    
    
    
    // MARK: - Colors
    
    
    public var allColors: [LegoColor] {
        
        dataStore.colors
    }
    
    
    public func color(forLegoColorId colorId: LegoColor.ID) -> Color? {
        
        if let c = dataStore.colors.first(where: { $0.id == colorId }) {
            return Color(fromBLCode: c.colorCode)
        } else {
            return nil
        }
    }
    
    
    public func colorName(forLegoColorId colorId: LegoColor.ID) -> String {
        
        return dataStore.colors.first(where: { $0.id == colorId })?.name ?? "\(colorId)"
    }
    
    
    private func loadColors() async {
        
        print("Loading colors")
        
        let blColors = await BrickLinkAPIClient.fetchColors(using: blCredentials)
        
        let colors = blColors.map {
            LegoColor(
                id: "\($0.colorId)",
                name: $0.colorName,
                colorCode: $0.colorCode
            )
        }
        
        try! dataStore.setColors(colors)
        try! dataStore.save()
    }
    
    
    func loadColorsIfMissing() async {
        
        if dataStore.colors.isEmpty {
            
            await loadColors()
        }
    }
    
    
    func reloadColors() async {
        
        if !dataStore.colors.isEmpty {
            
            await loadColors()
        }
    }
    
    
    
    // MARK: - Order summaries
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderStore.orderSummaries
    }
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderStore.orderSummary(forOrderWithId: orderId)
    }
    
    
    private func loadOrderSummaries() async {
        
        await orderStore.loadOrderSummaries()
    }
    
    
    public func reloadOrderSummaries() async {
        
        await orderStore.reloadOrderSummaries()
    }
    
    
    
    // MARK: - Orders details
    
    
    public var orderDetails: [OrderDetails] {
        
        orderStore.orderDetails
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderStore.orderDetails(forOrderWithId: orderId)
    }
    
    
    private func loadOrderDetails(forOrderWithId orderId: OrderSummary.ID) async {
        
        await orderStore.loadOrderDetails(forOrderWithId: orderId)
    }
    
    
    public func loadOrderDetailsIfMissing(forOrderWithId orderId: String) async {
        
        await orderStore.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
    
    
    
    // MARK: - Order status, Tracking no, Drive thru
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: OrderStatus) async {
        
        await orderStore.updateOrderStatus(orderId: orderId, status: status)
    }
    
    
    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        await orderStore.sendDriveThru(orderId: orderId)
    }
    
    
    
    // MARK: - Shipping
    
    
    public func shippingCost(forOrderWithId orderId: OrderSummary.ID) -> Float? {
        
        shippingStore.shippingCost(forOrderWithId: orderId)
    }
    
    
    public func selectedShippingCost(forOrderWithId orderId: OrderSummary.ID) -> SelectedShippingCost? {
        
        let order = orderDetails(forOrderWithId: orderId)!
        
        let weight = order.totalWeight * orderWeightMarginRatio
        
        if order.shippingMethodId == shippingMethodId_France_LaPoste {
            
            if let band = shippingCostBandsFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                    
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if order.shippingMethodId == shippingMethodId_Europe_LaPoste {
            
            if let band = shippingCostBandsEurope
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                  
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                        
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if order.shippingMethodId == shippingMethodId_World_LaPoste {
            
            if let band = shippingCostBandsWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                    
                var chooseLetter: Bool = false
                let chooseParcel: Bool = false
                var chooseParcelZB: Bool = false
                var chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    if ["US"].contains(order.shippingAddressCountryCode) {
                        chooseParcelZC = true
                        value = band.priceParcelZC
                    } else {
                        chooseParcelZB = true
                        value = band.priceParcelZB
                    }
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                        
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
        }
        
        return nil
    }
    
    
    public func recommendedStampingMethod(forOrderWithId orderId: OrderSummary.ID) -> String {
        
        let selectedShippingCost = selectedShippingCost(forOrderWithId: orderId)
        let order = orderDetails(forOrderWithId: orderId)!
        
        var s = ""
        
        if let selectedLetterStamping = selectedShippingCost?.letterStamping {
            
            if selectedLetterStamping.usePostOffice {
                return "Bureau de poste"
            } else {
                s = "\(selectedLetterStamping.nbTimbres ?? 0) timbres"
                
                if order.shippingMethodId != shippingMethodId_France_LaPoste {
                    s += " international"
                }
                
                return s
            }
        }
        
        return s
    }
    
    
    
    // MARK: - Stamping
    
    
    public func stamping(forOrderWithId orderId: OrderSummary.ID) -> String? {
        
        shippingStore.stamping(forOrderWithId: orderId)
    }
    
    
    public func orderIsValidatedWithoutStamping(orderId: OrderDetails.ID) -> Bool {
        
        shippingStore.orderIsValidatedWithoutStamping(orderId: orderId)
    }
    
    
    
    // MARK: - Order items
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        (dataStore.orderItemsByOrderId[orderId] ?? []).reduce([], { $0 + $1 })
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        let items = orderItems(forOrderWithId: orderId)
        
        return itemsIds.map { id in items.first { $0.id == id }! }
    }
    
    
    private func loadOrderItems(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order items \(orderId)")
        
        let blBatches = await BrickLinkAPIClient.fetchItems(forOrderWithId: orderId, using: blCredentials)
        
        let batches = blBatches.map { blItems in
            
            blItems.map { item in
                
                OrderItem(
                    inventoryId: "\(item.inventoryId)",
                    orderId: orderId,
                    condition: item.newOrUsed,
                    colorId: "\(item.colorId)",
                    colorName: item.colorName,
                    ref: item.item.no,
                    name: item.item.name.htmlUnescape(),
                    type: item.item.type,
                    location: item.remarks ?? "",
                    comment: (item.description ?? "").htmlUnescape(),
                    quantity: "\(item.quantity)",
                    unitPrice: item.unitPrice.floatValue,
                    unitPriceFinal: item.unitPriceFinal.floatValue
                )
            }
        }
        
        try! dataStore.setOrderItems(batches, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func loadOrderItemsIfMissing(forOrderWithId orderId: String) async {
        
        if !dataStore.orderItemsByOrderId.keys.contains(where: { $0 == orderId }) {
            
            await loadOrderItems(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderItems(forOrderWithId orderId: String) async {
        
        if dataStore.orderItemsByOrderId.keys.contains(where: { $0 == orderId }) {
            
            await loadOrderItems(forOrderWithId: orderId)
        }
    }
    
    
    
    // MARK: - Pick & Verify
    
    
    public func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return dataStore.pickedItemIdsByOrderId[orderId] ?? []
    }
    
    
    public func pickItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.addPickedItemId(itemId, toOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    public func pick(_ item: OrderItem) {
        
        pickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    public func unpickItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.removePickedItemId(itemId, fromOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    public func unpick(_ item: OrderItem) {
        
        unpickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    public func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return dataStore.verifiedItemIdsByOrderId[orderId] ?? []
    }
    
    
    public func verifyItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.addVerifiedItemId(itemId, toOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    public func verify(_ item: OrderItem) {
        
        verifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    public func unverifyItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.removeVerifiedItemId(itemId, fromOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    public func unverify(_ item: OrderItem) {
        
        unverifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    public func pickingProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        let total = orderItems(forOrderWithId: orderId).count
        let picked = pickedItemIds(forOrderWithId: orderId).count
        
        return Percent(Double(picked)/Double(total))
    }
    
    
    public func orderItemsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId)
            .filter { !pickedIds.contains($0.id) }
    }
    
    
    public func totalLotsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToPick(forOrderWithId: orderId).count
    }
    
    
    public func totalPartsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToPick(forOrderWithId: orderId).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func pickingVerificationProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        let total = orderItems(forOrderWithId: orderId).count
        let verified = verifiedItemIds(forOrderWithId: orderId).count
        
        return Percent(Double(verified)/Double(total))
    }
    
    
    public func orderItemsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId)
            .filter { !verifiedIds.contains($0.id) }
    }
    
    
    public func totalLotsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToVerify(forOrderWithId: orderId).count
    }
    
    
    public func totalPartsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToVerify(forOrderWithId: orderId).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func nextOrderItemsToPick(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId)
            .filter { !pickedIds.contains($0.id) }
            .sorted { $0.location < $1.location }
    }
    
    
    public func pickedOrderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId, fromItemIds: pickedIds).reversed()
    }
    
    
    public func nextOrderItemsToVerify(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
    
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        let verifiedIds = verifiedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId)
            .filter { pickedIds.contains($0.id) && !verifiedIds.contains($0.id) }
            .sorted { a, b in a.condition == "N" }
    }
    
    
    public func verifiedOrderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId, fromItemIds: verifiedIds).reversed()
    }
    
    
    
    // MARK: - Order feedback
    
    
    public func orderFeedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        dataStore.orderFeedbacksByOrderId[orderId] ?? []
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        orderFeedbacks(forOrderWithId: orderId).buyerFeedback()
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        orderFeedbacks(forOrderWithId: orderId).sellerFeedback()
    }
    
    
    private func loadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order feedbacks \(orderId)")
        
        let blFeedbacks = await BrickLinkAPIClient.fetchFeedbacks(forOrderWithId: orderId, using: blCredentials)
        let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
        
        try! dataStore.setOrderFeedbacks(feedbacks, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func loadOrderFeedbacksIfMissing(forOrderWithId orderId: OrderSummary.ID) async {
        
        if !dataStore.orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        if dataStore.orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func postOrderFeedback(orderId: OrderSummary.ID, rating: Int, comment: String) async {
        
        await BrickLinkAPIClient.postFeedback(forOrderWithId: orderId, rating: rating, comment: comment, using: blCredentials)
        
        await reloadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    public func postPraiseOrderFeedback(orderId: OrderSummary.ID) async {
        
        guard let order = orderDetails(forOrderWithId: orderId) else { return }
        
        await postOrderFeedback(
            orderId: orderId, rating: 0,
            comment: order.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
        )
    }
    
    
    public var dateValidatedWithoutFeedbackByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutFeedbackByOrderId
    }
    
    
    public func validateOrderWithoutFeedback(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutFeedback(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func dateOrderValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutFeedbackByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutFeedbackByOrderId[orderId] != nil
    }
    
    
    
    // MARK: - Upload
    
    
    public var uploadItems: [UploadItem] {
        
        dataStore.uploadItems
    }
    
    
    public var uploadItemsForList: [UploadItem] {
        
        uploadItems.sorted { item1, item2 in
                
            let rem1 = inventory(for: item1)?.remarks ?? inventories(forAllColorsOf: item1).map { $0.remarks }.sorted().first
            let rem2 = inventory(for: item2)?.remarks ?? inventories(forAllColorsOf: item2).map { $0.remarks }.sorted().first
            
            switch (rem1, rem2) {
                
            case (nil, nil):
                return true
                
            case (.some, nil):
                return true
                
            case (nil, .some):
                return false
                
            case (.some(let rem1), .some(let rem2)):
                return rem1 < rem2
            }
        }
    }
    
    
    public func addUploadItem(_ uploadItem: UploadItem) {
        
        try! dataStore.addUploadItem(uploadItem)
        try! dataStore.save()
    }
    
    
    public func deleteUploadItem(_ uploadItem: UploadItem) {
        
        try! dataStore.deleteUploadItem(uploadItem)
        try! dataStore.save()
    }
    
    
    public func updateUploadItem(_ updatedItem: UploadItem) {
        
        try! dataStore.updateUploadItem(updatedItem)
        try! dataStore.save()
    }
    
    
    public func importUploadList(fromXml xml: String) {
        
        let parser = XMLParser(data: Data(xml.utf8))
        let delegate = UploadListXMLParser()
        parser.delegate = delegate
        
        let success = parser.parse()
        guard success else {
            print("parsing failed")
            return
        }
        
        try! dataStore.addUploadItems(uploadItems)
        try! dataStore.save()
    }
    
    
    class UploadListXMLParser : NSObject, XMLParserDelegate {

        var uploadItems: [UploadItem] = []
        
        var ref: String = ""
        var colorId: String = ""
        var type: String = ""
        var qty: String = ""
        var unitPrice: String = ""
        var condition: String = ""
        var comment: String = ""
        
        var currentElementName: String? = nil
        
        func parser(
            _ parser: XMLParser,
            didStartElement elementName: String,
            namespaceURI: String?,
            qualifiedName qName: String?,
            attributes attributeDict: [String : String] = [:]
        ) {
            self.currentElementName = elementName
        }
        
        func parser(
            _ parser: XMLParser,
            didEndElement elementName: String,
            namespaceURI: String?,
            qualifiedName qName: String?
        ) {
            self.currentElementName = nil
            
            if elementName == "ITEM" {
                
                let ref: String = self.ref
                let type: BrickLinkItemType? = {
                    if self.type == "P" {
                        return BrickLinkItemType.part
                    }
                    return nil
                }()
                let colorId = self.colorId
                let qty = Int(self.qty)
                let condition = self.condition
                let unitPrice = Float(self.unitPrice)
                let comment = self.comment
                
                defer {
                    self.ref = ""
                    self.colorId = ""
                    self.type = ""
                    self.qty = ""
                    self.unitPrice = ""
                    self.condition = ""
                    self.comment = ""
                }
                
                guard let type = type else {
                    print("could not parse type: \(self.type)")
                    return
                }
                guard let qty = qty else {
                    print("could not parse qty: \(self.qty)")
                    return
                }
                guard let unitPrice = unitPrice else {
                    print("could not parse price: \(self.unitPrice)")
                    return
                }
                    
                self.uploadItems.append(UploadItem(
                    type: type,
                    ref: ref,
                    name: nil,
                    colorId: colorId,
                    qty: qty,
                    condition: condition,
                    comment: comment,
                    unitPrice: unitPrice
                ))
            }
        }
        
        func parser(
            _ parser: XMLParser,
            foundCharacters string: String
        ) {
            if let elementName = self.currentElementName {
                
                switch elementName {
                case "ITEMID":
                    ref = string
                case "COLOR":
                    colorId = string
                case "ITEMTYPE":
                    type = string
                case "QTY":
                    qty = string
                case "PRICE":
                    unitPrice = string
                case "CONDITION":
                    condition = string
                case "DESCRIPTION":
                    comment = string
                default:
                    break
                }
            }
        }
    }
    
    
    
    // MARK: - Uploaded items
    
    
    public var uploadedItems: [UploadedItem] {
        
        dataStore.uploadedItems
    }
    
    
    public func uploadedItemsForList(matching searchText: String) -> [UploadedItem] {
        
        uploadedItems
            .filter { $0.matches(searchText, self) }
            .sorted { $0.uploadDate > $1.uploadDate }
    }
    
    
    public func addUploadedItem(_ uploadedItem: UploadedItem) {
        
        try! dataStore.addUploadedItem(uploadedItem)
        try! dataStore.save()
    }
    
    
    // MARK: - Inventory
    
    
    public var inventories: [InventoryItem] {
        
        dataStore.inventories
    }
    
    
    public func inventory(withId id: InventoryItem.ID) -> InventoryItem? {
        
        dataStore.inventories.first { $0.id == id }
    }
    
    
    public func inventory(
        
        forType type: BrickLinkItemType,
        ref: String,
        comment: String?,
        colorId: String,
        condition: String
    
    ) -> InventoryItem? {
        
        return inventories.first {
            
            $0.type == type
            && $0.ref == ref
            && $0.description == (comment ?? "")
            && $0.colorId == colorId
            && $0.condition == condition
        }
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        return inventories.first {
            
            $0.type == uploadItem.type
            && $0.ref == uploadItem.ref
            && $0.description == (uploadItem.comment ?? "")
            && $0.colorId == uploadItem.colorId
            && $0.condition == uploadItem.condition
        }
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        return inventories.filter {
            
            $0.type == uploadItem.type
            && $0.ref == uploadItem.ref
            && $0.description == (uploadItem.comment ?? "")
            && $0.condition == uploadItem.condition
        }
    }
    
    
    private func loadInventories() async {
        
        print("Loading inventories")
        
        let blInventories = await BrickLinkAPIClient.fetchInventories(using: blCredentials)
        
        let inventories = blInventories.map {
            InventoryItem(fromBl: $0)
        }
        
        try! dataStore.setInventories(inventories)
        try! dataStore.save()
    }
    
    
    public func loadInventory(withId id: InventoryItem.ID) async {
        
        let blInventory = await BrickLinkAPIClient.fetchInventory(withId: id, using: blCredentials)
        let inventory = InventoryItem(fromBl: blInventory)
        
        try! dataStore.setInventory(inventory)
        try! dataStore.save()
    }
    
    
    public func reloadInventories() async {
        
        if !dataStore.inventories.isEmpty {
        
            await loadInventories()
        }
    }
    
    
    public func reloadInventory(withId id: InventoryItem.ID) async {
        
        if dataStore.inventories.contains(where: { $0.id == id }) {
            
            await loadInventory(withId: id)
        }
    }
    
    
    public func getInventory(for uploadItem: UploadItem) async -> InventoryItem? {
        
        let inventories = await BrickLinkAPIClient.fetchInventories(matchingItemType: uploadItem.type, matchingColorId: uploadItem.colorId, using: blCredentials)
            
        if let inv = inventories.first(where: { inv in
            
            inv.item.type == uploadItem.type
            && inv.item.no == uploadItem.ref
            && "\(inv.colorId)" == uploadItem.colorId
            && inv.newOrUsed == uploadItem.condition
            && (inv.description ?? "") == (uploadItem.comment ?? "")
        }) {
            return InventoryItem(fromBl: inv)
        }
        
        return nil
    }
    
    
    public func createInventory(
        
        ref: String,
        type: BrickLinkItemType,
        colorId: String,
        quantity: Int,
        unitPrice: Float,
        condition: String,
        description: String?,
        remarks: String
        
    ) async -> InventoryItem? {
        
        let blInventory = await BrickLinkAPIClient.createInventory(
            
            ref: ref,
            type: type,
            colorId: colorId,
            quantity: quantity,
            unitPrice: unitPrice,
            condition: condition,
            description: description,
            remarks: remarks,
            
            using: blCredentials
        )
        
        let inventory = InventoryItem(fromBl: blInventory)
        
        await self.reloadInventories()
        
        return inventory
    }
    
    
    public func updateInventory(
        
        id: InventoryItem.ID,
        
        addQuantity: Int,
        unitPrice: Float? = nil,
        remarks: String? = nil
    
    ) async {
        
        await BrickLinkAPIClient.updateInventory(
            
            id: id,
        
            addQuantity: addQuantity,
            unitPrice: unitPrice,
            remarks: remarks,
            
            using: blCredentials
        )
        
        await self.reloadInventory(withId: id)
    }
    
    
    
    // MARK: - Quantity
    
    
    public func inStockQuantity(
        
        forType type: BrickLinkItemType,
        ref: String,
        comment: String?,
        colorId: String,
        condition: String
    
    ) -> Int {
        
        let inventory = inventory(
            
            forType: type,
            ref: ref,
            comment: comment,
            colorId: colorId,
            condition: condition
        )
        
        let inventoryQty = inventory?.quantity ?? 0
        
        let itemsNotPickedYet = orderSummaries.filter {
            
            macroStatus(forOrderWithId: $0.id).isOneOf(.validatePayment, .pickAndPack)
            
        }.flatMap { order in
            
            orderItems(forOrderWithId: order.id).filter { item in
                
                !pickedItemIds(forOrderWithId: order.id).contains(item.id)
            }
        }
        
        let pendingQty = itemsNotPickedYet.filter {
            
            $0.type == type
            && $0.ref == ref
            && $0.comment == (comment ?? "")
            && $0.colorId == colorId
            && $0.condition == condition
            
        }.reduce(0, { $0 + Int($1.quantity)! })
        
        return inventoryQty + pendingQty
    }
    
    
    public func inStockQuantity(for orderItem: OrderItem) -> Int {
        
        return inStockQuantity(
            
            forType: orderItem.type,
            ref: orderItem.ref,
            comment: orderItem.comment,
            colorId: orderItem.colorId,
            condition: orderItem.condition
        )
    }
    
    
    public func inStockQuantityBeforeAfter(for orderItem: OrderItem) -> (before: Int, after: Int) {
        
        let itemIsPicked = pickedItemIds(forOrderWithId: orderItem.orderId).contains(orderItem.id)
        let stock = inStockQuantity(for: orderItem)
        let qty = Int(orderItem.quantity)!
        
        if !itemIsPicked {
            return (before: stock, after: stock - qty)
        } else {
            return (before: stock + qty, after: stock)
        }
    }
    
    
    
    // MARK: - Catalog
    
    
    public func getCatalogItem(forItemType type: BrickLinkItemType, ref: String) async -> CatalogItem? {
        
        if let catalogItem = await BrickLinkAPIClient.fetchCatalogEntry(forItemType: type, ref: ref, using: blCredentials) {
            
            return CatalogItem(fromBl: catalogItem)
        }
        
        return nil
    }
    
    
    
    // MARK: - Transactions
    
    
    public var transactions: [Transaction] {
        
        dataStore.transactions
    }
    
    
    public func registerTransaction(_ transaction: Transaction) {
        
        try! dataStore.addTransaction(transaction)
        try! dataStore.save()
    }
    
    
    public func incomeTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        return transactions.filter { $0.type == .orderIncome && $0.orderRefIn == orderId }
    }
    
    
    public func shippingTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        return transactions.filter { $0.type == .orderShipping && $0.orderRefIn == orderId }
    }
    
    
    public func refundTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        return transactions.filter { $0.type == .orderRefund && $0.orderRefIn == orderId }
    }
    
    
    public var dateValidatedWithoutIncomeTransactionByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutIncomeTransactionByOrderId
    }
    
    
    public func validateOrderWithoutIncomeTransaction(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutIncomeTransaction(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func dateOrderValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutIncomeTransactionByOrderId[orderId] != nil
    }
    
    
    public var dateValidatedWithoutShippingTransactionByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutShippingTransactionByOrderId
    }
    
    
    public func validateOrderWithoutShippingTransaction(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutShippingTransaction(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func dateOrderValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutShippingTransactionByOrderId[orderId] != nil
    }
    
    
    
    // MARK: - Import & Refresh
    
    
    private func loadMissingOrders() async {
        
        for order in orderSummaries {
            
            await loadOrderDetailsIfMissing(forOrderWithId: order.id)
            await loadOrderItemsIfMissing(forOrderWithId: order.id)
            await loadOrderFeedbacksIfMissing(forOrderWithId: order.id)
        }
    }
    
    
    public func refreshAllOrders() async {
        
        for order in orderSummaries {
            
            await refreshOrder(orderId: order.id)
        }
    }
    
    
    public func refreshOrder(orderId: OrderSummary.ID) async {
        
        if shouldRefreshOrder(orderId: orderId) {
            
            await loadOrderDetails(forOrderWithId: orderId)
            await loadOrderItems(forOrderWithId: orderId)
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func forceRefreshOrder(orderId: OrderSummary.ID) async {
        
        await loadOrderDetails(forOrderWithId: orderId)
        await loadOrderItems(forOrderWithId: orderId)
        await loadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    private func orderIsClosedForMoreThan30Days(orderId: OrderSummary.ID) -> Bool {
        
        let orderSummary = orderSummary(forOrderWithId: orderId)!
        
        return (
            orderSummary.status.isOneOf(.completed, .cancelled, .purged)
            &&
            orderSummary.dateStatusChanged.days(to: Date()) > 30
        )
    }
    
    
    private func shouldRefreshOrder(orderId: OrderSummary.ID) -> Bool {
        
        if orderIsClosedForMoreThan30Days(orderId: orderId) {
            
            guard
                let orderDetails = orderDetails(forOrderWithId: orderId)
            else {
                return true
            }
            
            let orderItems = orderItems(forOrderWithId: orderId)
            if orderItems.isEmpty {
                
                return true
            }
            
            let orderSummary = orderSummary(forOrderWithId: orderId)!
            if orderDetails.differs(from: orderSummary) {
                
                return true
            }
            
            let feedbacks = orderFeedbacks(forOrderWithId: orderId)
            if !feedbacks.hasSellerFeedback() {
                
                return true
            }
            
            return false
            
        } else {
        
            return true
        }
    }
    
    
    public func refreshOrdersMainList() async {
        
        await reloadOrderSummaries()
        
        let allOrders = orderSummaries
        
        let ordersThatNeedRefreshLaPosteTrackingStatus = allOrders
            .filter { macroStatus(forOrderWithId: $0.id) == .inTransit }
        
        for order in ordersThatNeedRefreshLaPosteTrackingStatus {
            await reloadLaPosteTrackingStatus(forOrderWithId: order.id)
        }
        
        let ordersThatNeedRefreshFeedback = allOrders
            .filter { macroStatus(forOrderWithId: $0.id).isOneOf(.received, .giveFeedback) }
        
        for order in ordersThatNeedRefreshFeedback {
            await reloadOrderFeedbacks(forOrderWithId: order.id)
        }
    }
    
    
    
    // MARK: - Profit margin
    
    
    public func profitMargin(for order: OrderDetails) -> Float? {
        
        return profitMargin(
            
            totalItems: order.subTotal,
            totalShipping: order.shippingCost,
        
            itemsCost: 0,
            shippingCost: shippingCost(forOrderWithId: order.id),
            
            fees: fees(for: order),
            refund: refunds(for: order).reduce(0, { $0 + $1.amount })
        )
    }
    
    
    public func profitMargin(
    
        totalItems: Float?,
        totalShipping: Float?,
    
        itemsCost: Float?,
        shippingCost: Float?,
        
        fees: Float?,
        refund: Float?
        
    ) -> Float? {
        
        if
            let totalItems = totalItems,
            let totalShipping = totalShipping,
            
            let itemsCost = itemsCost,
            let shippingCost = shippingCost,
            
            let fees = fees
        {
            let totalIncome = totalItems + totalShipping
            let totalExpense = itemsCost + shippingCost + fees + (refund ?? 0)
            
            return (totalIncome - totalExpense) / totalIncome
        }
        
        return nil
    }
    
    
    public func fees(for order: OrderDetails) -> Float? {
        
        let incomeTransactionsFees = incomeTransactions(forOrderWithId: order.id).compactMap { $0.fees }.reduce(0, +)
        let refundTransactionsFees = refundTransactions(forOrderWithId: order.id).compactMap { $0.fees }.reduce(0, +)
        
        return incomeTransactionsFees - refundTransactionsFees
    }
    
    
    var resultDashboardModel: ResultDashboardModel {
        
        let periodNLastDays = 30
        
        let orders = orderDetails
            .filter { $0.date.days(to: .now) < periodNLastDays }
            .filter { self.profitMargin(for: $0) != nil }
            .sorted { (self.profitMargin(for: $0) ?? 0) > (self.profitMargin(for: $1) ?? 0) }
        
        let totalItems = orders.reduce(0) { $0 + $1.subTotal }
        let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
        
        let totalItemCost: Float = 0
        let totalShippingCost = orders.reduce(0) { $0 + (shippingCost(forOrderWithId: $1.id) ?? 0) }
        
        let totalFees = orders.reduce(0) { $0 + (fees(for: $1) ?? 0) }
        let totalRefund = orders.flatMap { refunds(for: $0) }.reduce(0) { $0 + $1.amount }
        
        let totalResult = totalItems + totalShipping - totalItemCost - totalShippingCost - totalFees - totalRefund
        
        let profitMargin = profitMargin(
            
            totalItems: totalItems,
            totalShipping: totalShipping,
            
            itemsCost: totalItemCost,
            shippingCost: totalShippingCost,
            
            fees: totalFees,
            refund: totalRefund
            
        ) ?? 0
        
        return ResultDashboardModel(
            periodNLastDays: periodNLastDays,
            orders: orders,
            totalItems: totalItems,
            totalShipping: totalShipping,
            totalItemCost: totalItemCost,
            totalShippingCost: totalShippingCost,
            totalFees: totalFees,
            totalRefund: totalRefund,
            totalResult: totalResult,
            profitMargin: profitMargin
        )
    }
    
    
    
    // MARK: - Refunds
    
    
    public var orderRefunds: [OrderRefund] {
        
        dataStore.orderRefunds
    }
    
    
    public func refunds(for order: OrderDetails) -> [OrderRefund] {
        
        orderRefunds.filter { $0.orderId == order.id }
    }
    
    
    public func createRefund(_ refund: OrderRefund) {
        
        try! dataStore.addOrderRefund(refund)
        try! dataStore.save()
    }
    
    
    
    // MARK: - Order checklist
    
    
    public func orderChecklistPayment(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.paymentStatus.isOneOf(.completed, .received)
    }
    
    
    public func orderChecklistIncomeTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        if orderIsValidatedWithoutIncomeTransaction(orderId: orderId) {
            return true
        }
        return !incomeTransactions(forOrderWithId: orderId).isEmpty
    }
    
    
    public func orderChecklistShippingTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        if !shippingTransactions(forOrderWithId: orderId).isEmpty {
            
            return true
        }
        
        if orderIsValidatedWithoutShippingTransaction(orderId: orderId) {
            
            return true
        }
        
        let order = orderDetails(forOrderWithId: orderId)!
        if order.shippingMethodId.isOneOf(shippingMethodIds_LaPoste) {
        
            let stamping = stamping(forOrderWithId: orderId)
            if !(stamping ?? "").isEmpty, stamping != "Bureau de poste" {
                
                return true
            }
        }
        
        return false
    }
    
    
    public func orderChecklistPicking(_ orderId: OrderSummary.ID) -> Bool {
        
        let items = orderItems(forOrderWithId: orderId)
        
        let pickedItemIds = pickedItemIds(forOrderWithId: orderId)
        
        return items.allSatisfy { pickedItemIds.contains($0.id) }
    }
    
    
    public func orderChecklistVerification(_ orderId: OrderSummary.ID) -> Bool {
        
        let items = orderItems(forOrderWithId: orderId)
        
        let verifiedItemIds = verifiedItemIds(forOrderWithId: orderId)
        
        return items.allSatisfy { verifiedItemIds.contains($0.id) }
    }
    
    
    public func orderChecklistPacked(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status.isOneOf(.packed, .shipped, .received, .completed)
    }
    
    
    public func orderChecklistShipped(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status.isOneOf(.shipped, .received, .completed)
    }
    
    
    public func orderChecklistTrackingNo(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderDetails(forOrderWithId: orderId)!
        
        return !(order.trackingNo ?? "").isEmpty
    }
    
    
    public func orderChecklistDriveThru(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderDetails(forOrderWithId: orderId)!
        
        return order.driveThruSent
    }
    
    
    public func orderChecklistStamping(_ orderId: OrderSummary.ID) -> Bool {
        
        if orderIsValidatedWithoutStamping(orderId: orderId) {
            return true
        }
        
        let order = orderDetails(forOrderWithId: orderId)!
        if order.shippingMethodId == shippingMethodId_France_MondialRelay {
            return true
        }
        
        let stamping = stamping(forOrderWithId: orderId)
        
        return !(stamping ?? "").isEmpty
    }
    
    
    public func orderChecklistReceived(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status.isOneOf(.received, .completed)
    }
    
    
    public func orderChecklistCompleted(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status == .completed
    }
    
    
    public func orderChecklistBuyerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        return orderFeedbacks(forOrderWithId: orderId).buyerFeedback() != nil
    }
    
    
    public func orderChecklistSellerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        if orderIsValidatedWithoutFeedback(orderId: orderId) {
            return true
        }
        
        return orderFeedbacks(forOrderWithId: orderId).sellerFeedback() != nil
    }
    
    
    public func orderChecklistUnchangedFor30Days(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.dateStatusChanged.days(to: Date()) > 30
    }
    
    
    
    // MARK: - Order macro status
    
    
    public func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        if order.status.isOneOf(.cancelled, .purged) {
            return orderChecklistUnchangedFor30Days(orderId) ? .closed : .recentlyClosed
        }
        
        let initialStatus: OrderMacroStatus = .validatePayment
        
        let conditionsStatus: [
            (condition: () -> Bool, status: OrderMacroStatus)
        ] = [
            (condition: {
                self.orderChecklistIncomeTransaction(orderId)
                
            }, status: .pickAndPack
            ),
            (condition: {
                self.orderChecklistPicking(orderId)
                && self.orderChecklistVerification(orderId)
                && self.orderChecklistPacked(orderId)
                
            }, status: .ship
            ),
            (condition: {
                self.orderChecklistStamping(orderId)
                && self.orderChecklistShippingTransaction(orderId)
                && self.orderChecklistTrackingNo(orderId)
                && self.orderChecklistShipped(orderId)
                && self.orderChecklistDriveThru(orderId)
                
            }, status: .inTransit
            ),
            (condition: {
                self.orderChecklistReceived(orderId)
                
            }, status: .received
            ),
            (condition: {
                self.orderChecklistCompleted(orderId)
                || self.orderChecklistBuyerFeedback(orderId)
                || self.orderChecklistUnchangedFor30Days(orderId)
                
            }, status: .giveFeedback
            ),
            (condition: {
                self.orderChecklistSellerFeedback(orderId)
                
            }, status: .closed
            )
        ]
        
        var status = {
            
            var validatedStatus = initialStatus
            for c in conditionsStatus {
                if c.condition() {
                    validatedStatus = c.status
                    continue
                } else {
                    return validatedStatus
                }
            }
            return validatedStatus
        }()
        
        if status == .inTransit, orderChecklistUnchangedFor30Days(orderId) {
            status = .inTransitFor30PlusDays
        }
        
        if status == .closed, !orderChecklistUnchangedFor30Days(orderId) {
            status = .recentlyClosed
        }
        
        return status
    }
    
    
    public func ordersMainListSections(restrictingToOrdersMatching searchText: String) -> [OrdersMainListSection] {
        
        let orders = orderSummaries.filter { $0.matches(searchText) }
        
        var sections: [OrdersMainListSection] = [
            
            .init(
                header: OrderMacroStatus.inTransitFor30PlusDays.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .inTransitFor30PlusDays }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.giveFeedback.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .giveFeedback }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.validatePayment.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .validatePayment }
                    .sorted { $0.date > $1.date }
            ),
            .init(
                header: OrderMacroStatus.pickAndPack.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .pickAndPack }
                    .sorted {
                        orderChecklistVerification($0.id) != orderChecklistVerification($1.id)
                        && orderChecklistVerification($0.id)
                        ||
                        orderChecklistVerification($0.id) != orderChecklistVerification($1.id)
                        && $0.lots < $1.lots
                    }
            ),
            .init(
                header: OrderMacroStatus.ship.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .ship }
                    .sorted { $0.date > $1.date }
            ),
            .init(
                header: OrderMacroStatus.received.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .received }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.inTransit.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .inTransit }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.recentlyClosed.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .recentlyClosed }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
        ]
        
        let closedOrders = orders
            .filter { macroStatus(forOrderWithId: $0.id) == .closed }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
        
        sections.append(contentsOf: closedOrders.grouppedByMonth.map { item in
            .init(
                header: "􀤟 \(item.month)",
                orders: item.elements
            )
        })
        
        return sections
    }
    
    
    
    // MARK: - Orders actions
    
    
    var ordersThatNeedCompletedAndGiveFeedback: [OrderSummary] {
        
        orderSummaries
            .filter { macroStatus(forOrderWithId: $0.id) == .inTransitFor30PlusDays }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    var ordersThatNeedGiveFeedback: [OrderSummary] {
        
        orderSummaries
            .filter { macroStatus(forOrderWithId: $0.id) == .giveFeedback }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
    }
    
    
    var ordersToShipAndSendDriveThru: [OrderSummary] {
        
        orderSummaries
            .filter {
                macroStatus(forOrderWithId: $0.id) == .ship
                && orderChecklistStamping($0.id)
                && orderChecklistShippingTransaction($0.id)
                && orderChecklistTrackingNo($0.id)
            }
            .sorted { $0.date > $1.date }
    }
    
    
    var ordersThatNeedAction: [OrderSummary] {
        
        ordersThatNeedCompletedAndGiveFeedback
        + ordersThatNeedGiveFeedback
        + ordersToShipAndSendDriveThru
    }
    
    
    public func performActionForAllOrders() async {
        
        for order in ordersThatNeedCompletedAndGiveFeedback {
        
            await updateOrderStatus(orderId: order.id, status: .completed)
            await postPraiseOrderFeedback(orderId: order.id)
        }
        
        for order in ordersThatNeedGiveFeedback {
            
            await postPraiseOrderFeedback(orderId: order.id)
        }
        
        for order in ordersToShipAndSendDriveThru {
            
            await updateOrderStatus(orderId: order.id, status: .shipped)
            await sendDriveThru(orderId: order.id)
        }
    }
    
    
    
    // MARK: - Tracking status
    
    
    public func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        dataStore.laPosteTrackingStatusByTrackingNo[trackingNo]
    }
    
    
    public func laPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) -> LaPosteTrackingStatus? {
        
        if let order = orderDetails(forOrderWithId: orderId),
           let trackingNo = order.trackingNo {
            
            return laPosteTrackingStatus(forTrackingNo: trackingNo)
        } else {
            return nil
        }
    }
    
    
    private func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        let status = await LaPosteTrackingClient.fetchTrackingStatus(forTrackingNo: trackingNo)
    
        try! dataStore.setLaPosteTrackingStatus(status, forTrackingNo: trackingNo)
        try! dataStore.save()
    }
    
    
    private func loadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        let order = orderDetails(forOrderWithId: orderId)!
        let trackingNo = order.trackingNo!
            
        await loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
    
    
    public func reloadLaPosteTrackingStatus(forOrderWithId orderId: OrderSummary.ID) async {
        
        await loadLaPosteTrackingStatus(forOrderWithId: orderId)
    }
    
    
    
    // MARK: - Action orders
    
    
    public var actionOrders: [OrderSummary] {
        
        orderSummaries.filter {
            macroStatus(forOrderWithId: $0.id).isOneOf(
                .ship, .pickAndPack, .validatePayment, .giveFeedback, .inTransitFor30PlusDays
            )
        }
    }
}



// MARK: - Decoding



extension OrderSummary {
    
    
    init(fromBl bl: BrickLinkOrder) {
        
        self.id = "\(bl.orderId)"
        self.date = bl.dateOrdered
        self.buyer = bl.buyerName
        self.items = bl.totalCount
        self.lots = bl.uniqueCount
        
        self.subTotal = bl.cost.subtotal.floatValue
        self.grandTotal = bl.cost.grandTotal.floatValue
        self.costCurrencyCode = bl.cost.currencyCode
        
        self.dispSubTotal = bl.dispCost.subtotal.floatValue
        self.dispGrandTotal = bl.dispCost.grandTotal.floatValue
        self.dispCostCurrencyCode = bl.dispCost.currencyCode
        
        self.status = OrderStatus(rawValue: bl.status)!
        self.dateStatusChanged = bl.dateStatusChanged
        
        self.paymentStatus = PaymentStatus(rawValue: bl.payment.status)!
    }
}


extension OrderDetails {
    
    
    init(fromBl bl: BrickLinkOrder) {
        
        self.id = "\(bl.orderId)"
        self.date = bl.dateOrdered
        self.buyer = bl.buyerName
        self.items = bl.totalCount
        self.lots = bl.uniqueCount
        
        self.subTotal = bl.cost.subtotal.floatValue
        self.grandTotal = bl.cost.grandTotal.floatValue
        self.shippingCost = bl.cost.shipping!.floatValue
        self.costCurrencyCode = bl.cost.currencyCode
        
        self.dispSubTotal = bl.dispCost.subtotal.floatValue
        self.dispGrandTotal = bl.dispCost.grandTotal.floatValue
        self.dispShippingCost = bl.dispCost.shipping!.floatValue
        self.dispCostCurrencyCode = bl.dispCost.currencyCode
        
        self.status = OrderStatus(rawValue: bl.status)!
        self.driveThruSent = bl.driveThruSent!
        self.trackingNo = bl.shipping!.trackingNo
        self.totalWeight = bl.totalWeight!.floatValue
        
        self.shippingMethodId = bl.shipping!.methodId
        self.shippingMethodName = bl.shipping!.method
        self.shippingAddress = bl.shipping!.address.full.htmlUnescape()
        self.shippingAddressCountryCode = bl.shipping!.address.countryCode
        self.shippingAddressName = bl.shipping!.address.name.full
        
        self.remarks = bl.remarks
    }
}


extension InventoryItem {
    
    
    init(fromBl bl: BrickLinkInventoryItem) {
        
        self.id = "\(bl.inventoryId)"
        self.condition = bl.newOrUsed
        self.colorId = "\(bl.colorId)"
        self.ref = bl.item.no
        self.name = bl.item.name
        self.type = bl.item.type
        self.description = bl.description ?? ""
        self.remarks = bl.remarks ?? ""
        self.quantity = bl.quantity
        self.unitPrice = bl.unitPrice.floatValue
    }
}


extension CatalogItem {
    
    
    init(fromBl bl: BrickLinkCatalogItem) {
        
        self.name = bl.name.htmlUnescape()
    }
}


extension Feedback {
    
    
    init(fromBl bl: BrickLinkOrderFeedback) {
        
        self.id = bl.feedbackId
        self.orderId = "\(bl.orderId)"
        self.from = bl.from
        self.to = bl.to
        self.dateRated = bl.dateRated
        self.rating = bl.rating
        self.author = FeedbackAuthor(fromBl: bl.ratingOfBs)!
        self.comment = bl.comment
    }
}


extension FeedbackAuthor {
    
    
    init?(fromBl ratingOfBs: String) {
        
        switch ratingOfBs {
          
        case "B": self = .seller
        case "S": self = .buyer
            
        default: return nil
        }
    }
}


extension Data {
    
    
    func decode<T>() -> T where T: Decodable {
        
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        decoder.dateDecodingStrategy = .custom({ (decoder) in
            
            let stringValue = try! decoder.singleValueContainer().decode(String.self)
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
            
            return dateFormatter.date(from: stringValue)!
        })
        
        let decoded = try! decoder.decode(T.self, from: self)
        
        return decoded
    }
}
