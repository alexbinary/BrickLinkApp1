
import SwiftUI



struct OrderPickingProgressView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {

        Grid(alignment: .leading) {
            
            GridRow {
                Text("Picking")
                
                let percentPicked = app.percentPickedItems(forOrderWithId: order.id)
                Text(String(format: "%3.0f%% complete", percentPicked))
                
                if percentPicked < 1 {
                    let parts = app.numberOfPartsLeftToPick(forOrderWithId: order.id)
                    let lots = app.numberOfLotsLeftToPick(forOrderWithId: order.id)
                    Text("\(parts) parts in \(lots) lots left to pick")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
            
            GridRow {
                Text("Verify")
                
                let percentVerified = app.percentVerifiedItems(forOrderWithId: order.id)
                Text(String(format: "%3.0f%% verified", percentVerified))
                
                if percentVerified < 1 {
                    let parts = app.numberOfPartsLeftToVerify(forOrderWithId: order.id)
                    let lots = app.numberOfLotsLeftToVerify(forOrderWithId: order.id)
                    Text("\(parts) parts in \(lots) lots left to verify")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
        }
        .monospacedDigit()
    }
}

#Preview {
    let appController = AppController()
    let order = appController.orderDetails.first!
    OrderPickingProgressView(order).environmentObject(appController)
}
