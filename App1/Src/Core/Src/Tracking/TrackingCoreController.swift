
import Foundation



@MainActor
class TrackingCoreController {
    
    
    private let dataStore: DataStore
    private let updateController: UpdateController
    
    
    init(_ dataStore: DataStore, _ updateController: UpdateController) {
        
        self.dataStore = dataStore
        self.updateController = updateController
    }
    
    
    func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        dataStore.laPosteTrackingStatusByTrackingNo[trackingNo]
    }
    
    
    func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        await updateController.loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
}
