
import Foundation



class TrackingCoreController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    public func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        dataStore.laPosteTrackingStatusByTrackingNo[trackingNo]
    }
    
    
    public func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        let status = await LaPosteTrackingClient.fetchTrackingStatus(forTrackingNo: trackingNo)
    
        try! dataStore.setLaPosteTrackingStatus(status, forTrackingNo: trackingNo)
        try! dataStore.save()
    }
}
