
import SwiftUI


class AppController: ObservableObject {
    
    
    private let dataStore: DataStore
    

    init(dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    @Published var orders: [Order] = []
    
    
    func reloadOrders() {
        
        orders = [
        
            Order(id: "#1", date: "Aug 14, 2024", buyer: "legofan_fr", items: 248, lots: 71, grandTotal: 1681, status: "COMPLETED"),
            Order(id: "#2", date: "Aug 14, 2024", buyer: "legofan_fr", items: 248, lots: 71, grandTotal: 1681, status: "COMPLETED"),
        ]
    }
    
    
    func shippingCost(forOrderWithId id: String) -> Int {
        
        return dataStore.shippingCostsByOrderId[id] ?? 0
    }
    
    
    func updateShippingCost(forOrderWithId id: String, cost: Int) {
        
        var shippingCostsByOrderId = dataStore.shippingCostsByOrderId
        
        shippingCostsByOrderId[id] = cost
        
        try! dataStore.setShippingCostsByOrderId(shippingCostsByOrderId)
        try! dataStore.save()
    }
}
