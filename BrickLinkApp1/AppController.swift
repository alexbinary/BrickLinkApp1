
import SwiftUI


class AppController: ObservableObject {
    
    
    private let dataStore: DataStore
    

    init(dataStore: DataStore) {
        
        self.dataStore = dataStore
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
