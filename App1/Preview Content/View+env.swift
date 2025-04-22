
import SwiftUI



extension View {

    
    func env(
    
        defaultSelectedSidebarItem: SidebarItem? = nil,
        ordersNumberForSidebarBadge: Int = 0,
        uploadNumberForSidebarBadge: Int = 0
        
    ) -> some View {
        
        self
            .environment(\.navigationController, PreviewNavigationController(
                defaultSelectedSidebarItem: defaultSelectedSidebarItem
            ))
            .environment(\.orderStore, PreviewOrderStore(
                numberForSidebarBadge: ordersNumberForSidebarBadge
            ))
            .environment(\.uploadStore, PreviewUploadStore(
                numberForSidebarBadge: uploadNumberForSidebarBadge
            ))
    }
}
