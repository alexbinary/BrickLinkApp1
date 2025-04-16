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


    let frameSize = CGSize(width: 90, height: 70)
    let imageSize = CGSize(width: 80, height: 60)
    
    var body: some View {    
        
        ZStack {
            AsyncImage(url: catalog.url(forImageOfItemOfType: type, ref: ref, colorId: colorId)) { image in
                image
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize.width, height: imageSize.height)
            } placeholder: { Color.clear }
            
            if let data = catalog.data(forItemOfType: type, ref: ref, colorId: colorId) {
                if let length = data.lengthAnnotation {
                    annotationView(text: length, alignment: data.lengthAnnotationPosition)
                }
                if let dimensions = data.dimensionsAnnotation {
                    annotationView(text: dimensions, alignment: data.dimensionsAnnotationPosition)
                }
                if let chirality = data.chiralityAnnotation {
                    annotationView(text: chirality.rawValue, alignment: data.chiralityAnnotationPosition)
                }
            }
        }
        .frame(width: frameSize.width, height: frameSize.height, alignment: .center)
    }


    @ViewBuilder
    func annotationView(text: String, alignment: Alignment) -> some View {
        Text(text)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
            .clipShape(Capsule())
            .padding(2)
            .frame(width: imageSize.width, height: imageSize.height, alignment: alignment)
    }
}



#Preview {
    
    let env = createEnv()
    
    CatalogImage(itemType: .part, ref: "3001", colorId: "11")
        .inject(env)
}
