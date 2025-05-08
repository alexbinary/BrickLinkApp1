


extension OrderDetails {
    
    
    static func previewOrderDetailsWith(shippingAddress: String? = nil, shippingCost: Float? = nil) -> OrderDetails {
        .init(
            id: "",
            remarks: nil,
            
            totalWeight: 0,
            driveThruSent: false,
            trackingNo: nil,
            
            shippingMethodId: 0,
            shippingMethodName: nil,
            shippingAddress: shippingAddress ?? "",
            shippingAddressCountryCode: "",
            shippingAddressName: "",
            
            shippingCost: shippingCost ?? 0,
            dispShippingCost: 0
        )
    }
}
