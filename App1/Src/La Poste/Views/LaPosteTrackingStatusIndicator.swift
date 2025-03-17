
import SwiftUI


struct LaPosteTrackingStatusIndicator: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    let order: OrderSummary
    var status: LaPosteTrackingStatus? { app.laPosteTrackingStatus(forOrderWithId: order.id) }
    
    
    var body: some View {
        
        Text("La Poste: \(status?.rawValue ?? "")")
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .roundedContainer(style: .tag(baseColor: color))
            .onChange(of: order, initial: true) {
                Task { await app.reloadLaPosteTrackingStatus(forOrderWithId: order.id) }
            }
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
    
    let appController = AppController()
    let order = appController.orderSummaries.first!
    VStack {
        Group {
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
            LaPosteTrackingStatusIndicator(order: order)
        }.padding()
    }
    .environmentObject(appController)
}
