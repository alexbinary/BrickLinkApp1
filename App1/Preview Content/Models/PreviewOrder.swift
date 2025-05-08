


extension Order {
    
    
    static var previewOrder1: Order {
        
        .init(
            id: "",
            date: .now,
            dateStatusChanged: .now,
            buyer: "",
            status: .paid,
            items: 0,
            lots: 0,
            paymentStatus: .none,
            subTotal: 0,
            grandTotal: 0,
            costCurrencyCode: "",
            dispSubTotal: 0,
            dispGrandTotal: 0,
            dispCostCurrencyCode: ""
        )
    }
    
    static func previewOrderWith(id: String? = nil, subTotal: Float? = nil, grandTotal: Float? = nil) -> Order {
        .init(
            id: id ?? "",
            date: .now,
            dateStatusChanged: .now,
            buyer: "",
            status: .paid,
            items: 0,
            lots: 0,
            paymentStatus: .none,
            subTotal: subTotal ?? 0,
            grandTotal: grandTotal ?? 0,
            costCurrencyCode: "",
            dispSubTotal: 0,
            dispGrandTotal: 0,
            dispCostCurrencyCode: ""
        )
    }
}
