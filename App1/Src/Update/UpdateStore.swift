
import Foundation



@MainActor
protocol UpdateStoreProtocol {
    
    var isLoadingOperations: Bool { get }
    func isLoadingOperations(withTag tag: OperationTag) -> Bool
}



@Observable
@MainActor
class UpdateStore: UpdateStoreProtocol {
    
    
    private let updateController: UpdateController
    
    
    init(_ updateController: UpdateController) {
        
        self.updateController = updateController
    }
    
    
    var isLoadingOperations: Bool {
        
        updateController.isRunningOrIsScheduledToRun_anyOperation
    }
    
    
    func isLoadingOperations(withTag tag: OperationTag) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_operations(withTag: tag)
    }
}
