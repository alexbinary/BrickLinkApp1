
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
    
    
    var isLoadingLaPosteTrackingStatus: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus
    }
    
    
    func isLoadingLaPosteTrackingStatus(forTrackingNo trackingNo: String) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
}
