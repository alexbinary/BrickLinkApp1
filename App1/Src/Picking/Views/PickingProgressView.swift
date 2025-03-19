
import SwiftUI



struct PickingProgressView: View {
    
    
    @Environment(PickingController.self)
    var pickingController
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {

        Grid(alignment: .leading) {
            
            GridRow {
                Text("Picking")
                
                let progress = pickingController.pickingProgress(forOrderWithId: order.id)
                Text("\(progress) complete")
                
                if progress < 100% {
                    let parts = pickingController.totalPartsLeftToPick(forOrderWithId: order.id)
                    let lots = pickingController.totalLotsLeftToPick(forOrderWithId: order.id)
                    Text("\(parts) parts in \(lots) lots left to pick")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
            
            GridRow {
                Text("Verify")
                
                let progress = pickingController.pickingVerificationProgress(forOrderWithId: order.id)
                Text("\(progress) verified")
                
                if progress < 100% {
                    let parts = pickingController.totalPartsLeftToVerify(forOrderWithId: order.id)
                    let lots = pickingController.totalLotsLeftToVerify(forOrderWithId: order.id)
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
    let orderStore = appController.orderStore
    let pickingController = appController.pickingController
    
    let order = orderStore.orderDetails.first!
    
    PickingProgressView(order)
        .environment(pickingController)
}
