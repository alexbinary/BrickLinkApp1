
enum Secrets {

    enum BrickLink {
    
        static let consumerKey: String = "D3EEE632CCE54861B98B2655ADCCA813"
        static let consumerSecret: String = "3B13077372E6459B9108CDAD4677208C"

        static let tokenValue: String = "6F6DBA9C1E6E46A89B6A4808D7B73325"
        static let tokenSecret: String = "EE33AA93CF594B95BC77B74FB20E1075"
    }
    
    enum Default {
        
        static let selectedSidebarItem: SidebarItem = .orders
        static let ordersActiveNavigationPath: [OrderSummary.ID] = []//"27236825"]
        static let resultSelectedOrderIds: Set<OrderSummary.ID> = []
    }
}
