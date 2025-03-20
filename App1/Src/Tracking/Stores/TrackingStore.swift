
import Foundation



class TrackingStore {
    
    
    private let fileDataAccess: FileDataAccess
    
    
    init(_ fileDataAccess: FileDataAccess) {
        self.fileDataAccess = fileDataAccess
    }
    
    
    public func laPosteTrackingStatus(forTrackingNo trackingNo: String) -> LaPosteTrackingStatus? {
        
        fileDataAccess.laPosteTrackingStatusByTrackingNo[trackingNo]
    }
    
    
    public func loadLaPosteTrackingStatus(forTrackingNo trackingNo: String) async {
        
        let status = await LaPosteTrackingClient.fetchTrackingStatus(forTrackingNo: trackingNo)
    
        try! fileDataAccess.setLaPosteTrackingStatus(status, forTrackingNo: trackingNo)
        try! fileDataAccess.save()
    }
}
