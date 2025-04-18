
import Foundation


enum PreviewUtils {
    
    static var isPreviewing: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
