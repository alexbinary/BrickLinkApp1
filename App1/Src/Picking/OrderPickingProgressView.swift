
import SwiftUI
import Percentage



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
                
                let progress = app.pickingProgress(forOrderWithId: order.id)
                Text("\(progress) complete")
                
                if progress < 100% {
                    let parts = app.totalPartsLeftToPick(forOrderWithId: order.id)
                    let lots = app.totalLotsLeftToPick(forOrderWithId: order.id)
                    Text("\(parts) parts in \(lots) lots left to pick")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
            
            GridRow {
                Text("Verify")
                
                let progress = app.pickingVerificationProgress(forOrderWithId: order.id)
                Text("\(progress) verified")
                
                if progress < 100% {
                    let parts = app.totalPartsLeftToVerify(forOrderWithId: order.id)
                    let lots = app.totalLotsLeftToVerify(forOrderWithId: order.id)
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
