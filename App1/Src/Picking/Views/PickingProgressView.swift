
import SwiftUI



struct PickingProgressView: View {


    @Environment(\.pickingStore)
    var pickingStore: PickingStoreProtocol!


    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }


    var body: some View {
        
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 0) {

                HStack {

                    Text("Picking")
                        .font(.headline)
                    
                    let progress = pickingStore.pickingProgress(for: order)
                    Text("\(progress) complete")
                        .font(.subheadline)

                    if progress < 100% {
                        let parts = pickingStore.totalPartsLeftToPick(for: order)
                        let lots = pickingStore.totalLotsLeftToPick(for: order)
                        Text("\(parts) parts in \(lots) lots left to pick")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
                
                let progress = pickingStore.pickingProgress(for: order)
                ProgressView(value: progress.fractionValue).tint(.green)
            }
            
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Text("Verify")
                        .font(.headline)
                    
                    let progress = pickingStore.pickingVerificationProgress(for: order)
                    Text("\(progress) complete")
                        .font(.subheadline)

                    if progress < 100% {
                        let parts = pickingStore.totalPartsLeftToVerify(for: order)
                        let lots = pickingStore.totalLotsLeftToVerify(for: order)
                        Text("\(parts) parts in \(lots) lots left to verify")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
                
                let progress = pickingStore.pickingVerificationProgress(for: order)
                ProgressView(value: progress.fractionValue).tint(.green)
            }
        }
        .monospacedDigit()
    }
}



#Preview {

    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    PickingProgressView(order)
        .inject(env)
}
