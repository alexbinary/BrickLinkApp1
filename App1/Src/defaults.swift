


struct Defaults {
    
    
    let selectedSidebarItem: SidebarItem
    let ordersActiveNavigationPath: [Order.ID]
    let orderDetailActiveTab: OrderDetailTab?
    let resultSelectedOrderIds: Set<Order.ID> = []
    
    
    static let active = PreviewUtils.isPreviewing ? previewDefaults : Secrets.devDefaults
}
