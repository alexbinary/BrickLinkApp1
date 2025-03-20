
import SwiftUI



struct LegoColorView: View {
    
    
    @Environment(CatalogStore.self)
    var catalogStore
    
    
    let colorId: String
    let style: Style
    
    init(colorId: String, style: Style = .full) {
        self.colorId = colorId
        self.style = style
    }
    
    init(orderItem item: OrderItem, style: Style = .full) {
        self.colorId = item.colorId
        self.style = style
    }
    
    init(uploadItem item: UploadItem, style: Style = .full) {
        self.colorId = item.colorId
        self.style = style
    }
    
    init(uploadedItem item: UploadedItem, style: Style = .full) {
        self.colorId = item.colorId
        self.style = style
    }
    
    
    var body: some View {
        
        let (color, name) = catalogStore.colorAndName(forLegoColorId: colorId)
        
        HStack {
            
            color.frame(width: 18, height: 18)
            if style == .full { Text(name) }
        }
    }
    
    
    enum Style {
        
        case full
        case compact
    }
}



#Preview {
    
    let stores = createStores()
    
    LegoColorView(colorId: "11")
        .environment(stores.catalog)
}
