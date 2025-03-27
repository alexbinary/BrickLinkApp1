
import SwiftUI
import Core



struct PickingProgressView: View {
    
    
    @Environment(PickingStore.self)
    var pickingStore
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var body: some View {

        Grid(alignment: .leading) {
            
            GridRow {
                Text("Picking")
                
                let progress = pickingStore.pickingProgress(for: order)
                Text("\(progress) complete")
                
                if progress < 100% {
                    let parts = pickingStore.totalPartsLeftToPick(for: order)
                    let lots = pickingStore.totalLotsLeftToPick(for: order)
                    Text("\(parts) parts in \(lots) lots left to pick")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            }
            
            GridRow {
                Text("Verify")
                
                let progress = pickingStore.pickingVerificationProgress(for: order)
                Text("\(progress) verified")
                
                if progress < 100% {
                    let parts = pickingStore.totalPartsLeftToVerify(for: order)
                    let lots = pickingStore.totalLotsLeftToVerify(for: order)
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
    let order = env.stores.order.orderSummaries.first!
    
    PickingProgressView(order)
        .inject(env)
}
