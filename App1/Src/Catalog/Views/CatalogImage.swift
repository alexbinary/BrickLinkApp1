
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
        
        let frameSize = CGSize(width: 90, height: 70)
        let imageSize = CGSize(width: 80, height: 60)
        
        ZStack(alignment: .top) {
            AsyncImage(url: catalog.url(forImageOfItemOfType: type, ref: ref, colorId: colorId)) { image in
                image
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize.width, height: imageSize.height)
            } placeholder: { Color.clear }
            
            if let length = catalog.lengthAnnotation(forItemOfType: type, ref: ref, colorId: colorId) {
                Text(length)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                    .clipShape(Capsule())
                    .padding(2)
                    .frame(width: imageSize.width, height: imageSize.height, alignment: .bottomTrailing)
            }
        }
        .frame(width: frameSize.width, height: frameSize.height, alignment: .top)
    }
}



#Preview {
    
    let env = createEnv()
    
    CatalogImage(itemType: .part, ref: "3001", colorId: "11")
        .inject(env)
}
