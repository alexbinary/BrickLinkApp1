
import SwiftUI



struct LegoColorView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
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
        
        HStack {
            app.color(forLegoColorId: colorId).frame(width: 18, height: 18)
            if style == .full { Text(app.colorName(forLegoColorId: colorId)) }
        }
    }
    
    
    enum Style {
        
        case full
        case compact
    }
}



#Preview {
    LegoColorView(colorId: "11").environmentObject(AppController())
}
