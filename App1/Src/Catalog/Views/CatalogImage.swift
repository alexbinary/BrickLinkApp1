
import SwiftUI



struct CatalogImage: View {
    
    
    @Environment(Catalog.self)
    var catalog
    
    
    let type: ItemType
    let ref: String
    let colorId: String
    
    init(itemType type: ItemType, ref: String, colorId: String) {
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
        
        let width: CGFloat = 90
        let height: CGFloat = 70

        ZStack {
            AsyncImage(url: catalog.url(forImageOfItemOfType: type, ref: ref, colorId: colorId)) { image in
                image
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height, alignment: .top)
            } placeholder: { Color.clear }
            
            AsyncImage(url: catalog.url(forRebrickableLengthOverlayForItemOfType: type, ref: ref, colorId: colorId)) { image in
                image
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height, alignment: .topTrailing)
            } placeholder: { Color.clear }
        }
        .frame(width: width, height: height, alignment: .top)
    }
}



#Preview {
    
    let env = createEnv()
    
    CatalogImage(itemType: .part, ref: "3001", colorId: "11")
        .inject(env)
}
