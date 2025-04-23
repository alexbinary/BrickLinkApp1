import SwiftUI



struct CatalogImage: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
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
    
    init(inventoryItem item: InventoryItem) {
        self.type = item.type
        self.ref = item.ref
        self.colorId = item.colorId
    }


    let frameSize = CGSize(width: 84, height: 64)
    let imageSize = CGSize(width: 80, height: 60)
    
    var body: some View {    
        
        ZStack {
            AsyncImage(
                url: catalog.url(forImageOfItemOfType: type, ref: ref, colorId: colorId),
                transaction: SwiftUICore.Transaction(animation: .default),
                content: { phase in
                    Group {
                        switch phase {
                        case .success(let image):
                            image
                        case .failure(let error):
                            let _ = print(error)
                            Text("Error")
                        case .empty:
                            ProgressView().controlSize(.small)
                        @unknown default:
                            fatalError("Unkown state")
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize.width, height: imageSize.height)
                }
            )
            
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
    
    VStack {
        
        let baseView =
            CatalogImage(itemType: .part, ref: "", colorId: "")
                .padding(.top)
        
        baseView
            .previewEnv(
                catalog: PreviewCatalog(
                    urlForImageOfItemOfType: URL(string: "https://img.bricklink.com/P/11/3001.jpg"),
                )
            )
        baseView
            .previewEnv(
                catalog: PreviewCatalog(
                    urlForImageOfItemOfType: URL(string: "https://img.bricklink.com/P/11/3001.jpg"),
                    partData: .init(ref: "",
                                    lengthAnnotation: "4"
                                   )
                )
            )
        baseView
            .previewEnv(
                catalog: PreviewCatalog(
                    urlForImageOfItemOfType: URL(string: "https://img.bricklink.com/P/11/3001.jpg"),
                    partData: .init(ref: "",
                                    dimensionsAnnotation: "2x4"
                                   )
                )
            )
        baseView
            .previewEnv(
                catalog: PreviewCatalog(
                    urlForImageOfItemOfType: URL(string: "https://img.bricklink.com/P/11/3001.jpg"),
                    partData: .init(ref: "",
                                    chiralityAnnotation: .left
                                   )
                )
            )
        baseView
            .previewEnv(
                catalog: PreviewCatalog(
                    urlForImageOfItemOfType: URL(string: "broken")
                )
            )
    }
    .padding(.bottom)
    .padding(.horizontal)
}
