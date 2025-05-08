import SwiftUI



struct CatalogImage: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let part: PartDescriptor
    let scale: CGFloat
    
    let baseFrameSize = CGSize(width: 84, height: 64)
    let baseImageSize = CGSize(width: 80, height: 60)
    
    var frameSize: CGSize { baseFrameSize * scale }
    var imageSize: CGSize { baseImageSize * scale }
    
    
    init(item: PartDescriptible, scale: CGFloat = 1) {
        
        self.part = item.partDescriptor
        self.scale = scale
    }
    
    var type: ItemType { part.type! }
    var ref: String { part.ref! }
    var colorId: String { part.colorId! }
    
    var catalogUrl: URL? { catalog.url(forImageOf: part.withDefaults(colorId: "11")) }
    
    
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
            
            if let data = catalog.data(for: part) {
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
            CatalogImage(item: PartDescriptor(type: .part, ref: "", colorId: ""))
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
