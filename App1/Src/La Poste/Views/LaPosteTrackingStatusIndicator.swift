
import SwiftUI


struct LaPosteTrackingStatusIndicator: View {
    
    
    @Environment(TrackingController.self)
    var trackingController
    
    
    let order: OrderSummary
    var status: LaPosteTrackingStatus? { trackingController.laPosteTrackingStatus(forOrderWithId: order.id) }
    
    
    var body: some View {
        
        Text("La Poste: \(status?.rawValue ?? "")")
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .roundedContainer(style: .tag(baseColor: color))
            .onChange(of: order, initial: true) { Task {
                await trackingController.reloadLaPosteTrackingStatus(forOrderWithId: order.id)
            }}
    }
    
    
    var color: Color {
        switch status {
        case .none: .gray
        case .noData: .red
        case .inTransit: .yellow
        case .delivered: .green
        }
    }
}


#Preview {
    
    let controllers = AppController.createControllers()
    
    let orderController = controllers.orderController
    let trackingController = controllers.trackingController
    
    let order = orderController.orderSummaries.first!
    
    VStack {
        Group {
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
        }.padding()
    }
    .environment(trackingController)
}
