
import SwiftUI



struct PickingProgressView: View {
    
    
    @Environment(PickingStore.self)
    var pickingStore
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {

        Grid(alignment: .leading) {
            
            GridRow {
                Text("Picking")
                
                let progress = pickingStore.pickingProgress(forOrderWithId: order.id)
                Text("\(progress) complete")
                
                if progress < 100% {
                    let parts = pickingStore.totalPartsLeftToPick(forOrderWithId: order.id)
                    let lots = pickingStore.totalLotsLeftToPick(forOrderWithId: order.id)
                    Text("\(parts) parts in \(lots) lots left to pick")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
            
            GridRow {
                Text("Verify")
                
                let progress = pickingStore.pickingVerificationProgress(forOrderWithId: order.id)
                Text("\(progress) verified")
                
                if progress < 100% {
                    let parts = pickingStore.totalPartsLeftToVerify(forOrderWithId: order.id)
                    let lots = pickingStore.totalLotsLeftToVerify(forOrderWithId: order.id)
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
    
    let env = createEnv()
    
    let pickingStore = env.stores.picking
    
    let orderStore = env.stores.order
    let order = orderStore.orderDetails.first!
    
    PickingProgressView(order)
        .environment(pickingStore)
}
