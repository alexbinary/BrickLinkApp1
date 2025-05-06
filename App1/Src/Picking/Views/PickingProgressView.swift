
import SwiftUI



struct PickingProgressView: View {


    @Environment(\.pickingStore)
    var pickingStore: PickingStoreProtocol!
    
    @Namespace var animation


    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var pickingProgress: Percent {
        pickingStore.pickingProgress(for: order)
    }
    var verificationProgress: Percent {
        pickingStore.pickingVerificationProgress(for: order)
    }


    var body: some View {
        
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            
            let pickingView = VStack(alignment: .leading, spacing: 0) {

                HStack(alignment: .firstTextBaseline) {

                    Text("Picking")
                        .font(.headline)
                    
                    Text("\(pickingProgress) complete")
                        .font(.subheadline)

                    if pickingProgress < 100% {
                        let parts = pickingStore.totalPartsLeftToPick(for: order)
                        let lots = pickingStore.totalLotsLeftToPick(for: order)
                        Text("\(parts) parts in \(lots) lots left to pick")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("􀆅")
                            .foregroundStyle(green)
                    }
                }
                
                ProgressView(value: pickingProgress.fractionValue)
                    .tint(pickingProgress == 100% ? .green : .accentColor)
            }
                .matchedGeometryEffect(id: "picking", in: animation)
                
            
            let verificationView = VStack(alignment: .leading, spacing: 0) {

                HStack(alignment: .firstTextBaseline) {
                    
                    Text("Verify")
                        .font(.headline)
                    
                    Text("\(verificationProgress) complete")
                        .font(.subheadline)

                    if verificationProgress < 100% {
                        let parts = pickingStore.totalPartsLeftToVerify(for: order)
                        let lots = pickingStore.totalLotsLeftToVerify(for: order)
                        Text("\(parts) parts in \(lots) lots left to verify")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("􀆅")
                            .foregroundStyle(green)
                    }
                }
                
                ProgressView(value: verificationProgress.fractionValue)
                    .tint(verificationProgress == 100% ? .green : .accentColor)
            }
                .matchedGeometryEffect(id: "verification", in: animation)
            
            if pickingProgress < 100% {
                
                pickingView
                    .layoutPriority(1)
                    
                verificationView
                    .fixedSize()
                
            } else {
                
                pickingView
                    .fixedSize()
                
                verificationView
                    .layoutPriority(1)
            }
        }
        .monospacedDigit()
        .animation(.default, value: pickingProgress)
    }
}



#Preview {

    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    PickingProgressView(order)
        .inject(env)
}
