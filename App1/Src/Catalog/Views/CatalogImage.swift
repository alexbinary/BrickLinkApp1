import SwiftUI



struct CatalogImage: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let type: ItemType
    let ref: String
    let colorId: String
    let scale: CGFloat
    
    let baseFrameSize = CGSize(width: 84, height: 64)
    let baseImageSize = CGSize(width: 80, height: 60)
    
    var frameSize: CGSize { baseFrameSize * scale }
    var imageSize: CGSize { baseImageSize * scale }
    
    init(itemType type: ItemType, ref: String, colorId: String, scale: CGFloat = 1) {
        self.type = type
        self.ref = ref
        self.colorId = colorId
        self.scale = scale
    }
    
    init(item: PartIdentity, scale: CGFloat = 1) {
        self.type = item.item_type!
        self.ref = item.item_ref!
        self.colorId = item.item_colorId!
        self.scale = scale
    }
    
    init(orderItem item: OrderItem, scale: CGFloat = 1) {
        self.type = item.type
        self.ref = item.ref
        self.colorId = item.colorId
        self.scale = scale
    }
    
    init(uploadItem item: UploadItem, scale: CGFloat = 1) {
        self.type = item.type
        self.ref = item.ref
        self.colorId = item.colorId ?? ""
        self.scale = scale
    }
    
    init(uploadedItem item: UploadedItem, scale: CGFloat = 1) {
        self.type = item.type
        self.ref = item.ref
        self.colorId = item.colorId
        self.scale = scale
    }
    
    init(inventoryItem item: InventoryItem, scale: CGFloat = 1) {
        self.type = item.type
        self.ref = item.ref
        self.colorId = item.colorId
        self.scale = scale
    }
    
    
    var catalogUrl: URL? {
        
        let colorId = colorId.isEmpty ? "11" : colorId
        
        return catalog.url(forImageOfItemOfType: type, ref: ref, colorId: colorId)
    }
    
    
    var body: some View {
        
        ZStack {
            AsyncImage(
                url: catalogUrl,
                transaction: SwiftUICore.Transaction(animation: .default),
                content: { phase in
                    Group {
                        switch phase {
                        case .success(let image):
                            image.scaleEffect(scale)
                        case .failure(let error):
                            let _ = print(error)
                            Text("Failed to load image")
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
            .opacity(colorId.isEmpty ? 0.7 : 1)
            
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
                if data.variantAnnotation {
                    annotationView(text: "􀇿", alignment: data.variantAnnotationPosition, backgroundColor: .clear)
                        .foregroundStyle(.orange)
                }
            }
        }
        .frame(width: frameSize.width, height: frameSize.height, alignment: .center)
    }


    @ViewBuilder
    func annotationView(text: String, alignment: Alignment, backgroundColor: Color? = nil) -> some View {
        Text(text)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor ?? Color(NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
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
