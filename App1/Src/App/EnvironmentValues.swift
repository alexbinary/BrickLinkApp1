
import SwiftUI



extension EnvironmentValues {
    
    @Entry var catalog: CatalogProtocol?
    
    @Entry var inventoryStore: InventoryStoreProtocol?
    @Entry var uploadStore: UploadStoreProtocol?
    
    @Entry var orderStore: OrderStoreProtocol?
    @Entry var pickingStore: PickingStoreProtocol?
    @Entry var shippingStore: ShippingStoreProtocol?
    @Entry var trackingStore: TrackingStoreProtocol?
    @Entry var feedbackStore: FeedbackStoreProtocol?
}
