
import Foundation



@MainActor
class TrackingController {
    
    
    private let dataStore: DataStore
    private let updateController: UpdateController
    
    
    init(_ dataStore: DataStore, _ updateController: UpdateController) {
        
        self.dataStore = dataStore
        self.updateController = updateController
    }
    
    
    func laPosteTrackingStatus(forTrackingNo trackingNo: TrackingNo) -> LaPosteTrackingStatus? {
        
        dataStore.laPosteTrackingStatusByTrackingNo[trackingNo]
    }
    
    
    func loadLaPosteTrackingStatus(forTrackingNo trackingNo: TrackingNo, _ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await updateController.loadLaPosteTrackingStatus(forTrackingNo: trackingNo, refetchStrategy, operationTag)
    }
    
    
    var isLoadingLaPosteTrackingStatus: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus
    }
    
    
    func isLoadingLaPosteTrackingStatus(forTrackingNo trackingNo: TrackingNo) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadLaPosteTrackingStatus(forTrackingNo: trackingNo)
    }
}
