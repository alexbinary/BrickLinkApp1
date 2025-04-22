
import SwiftUI



struct LegoColorView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let colorId: String
    let style: Style
    
    init(colorId: String, style: Style = .default) {
        self.colorId = colorId
        self.style = style
    }
    
    init(orderItem item: OrderItem, style: Style = .default) {
        self.colorId = item.colorId
        self.style = style
    }
    
    init(uploadItem item: UploadItem, style: Style = .default) {
        self.colorId = item.colorId
        self.style = style
    }
    
    init(uploadedItem item: UploadedItem, style: Style = .default) {
        self.colorId = item.colorId
        self.style = style
    }
    
    
    var body: some View {
        
        let (color, name) = catalog.colorAndName(forLegoColorId: colorId)
        
        switch style {
        
        case .default:
            
            HStack {
                
                color.frame(width: 18, height: 18)
                Text(name)
            }
            
        case .colorSquareOnly:
            
            color.frame(width: 18, height: 18)
            
        case .nameOnly:
            
            Text(name)
        }
    }
    
    
    enum Style: String, CaseIterable {
        
        case `default`
        case colorSquareOnly
        case nameOnly
    }
}



#Preview {
    
    VStack(alignment: .leading) {
        
        ForEach(LegoColorView.Style.allCases, id: \.self) { style in
    
            VStack(alignment: .leading) {
                Text("Style: \(style)").font(.title3)
                LegoColorView(colorId: "", style: style)
            }
            .padding()
        }
    }
    .previewEnv(
        catalog: PreviewCatalog(
            color: LegoColor(id: "", name: "Color name", colorCode: "ff0000")
        )
    )
}
