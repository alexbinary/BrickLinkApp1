
import SwiftUI



struct CatalogImage: View {
    
    
    @Environment(CatalogStore.self)
    var catalogStore
    
    
    let type: BrickLinkItemType
    let ref: String
    let colorId: String
    
    init(itemType type: BrickLinkItemType, ref: String, colorId: String) {
        self.type = type
        self.ref = ref
        self.colorId = colorId
    }
    
    init(orderItem item: OrderItem) {
        self.type = item.type
        self.ref = item.ref
        self.colorId = item.colorId
    }
    
    init(uploadItem item: UploadItem) {
        self.type = item.type
        self.ref = item.ref
        self.colorId = item.colorId
    }
    
    init(uploadedItem item: UploadedItem) {
        self.type = item.type
        self.ref = item.ref
        self.colorId = item.colorId
    }
    

    var body: some View {

        AsyncImage(url: catalogStore.url(forCatalogImageOfItemOfType: type, ref: ref, colorId: colorId))
            .frame(minHeight: 70, maxHeight: 70, alignment: .top)
            .frame(minWidth: 90, maxWidth: 90, alignment: .top)
    }
}



#Preview {
    
    let stores = createStores()
    
    CatalogImage(itemType: .part, ref: "3001", colorId: "11")
        .environment(stores.catalog)
}
