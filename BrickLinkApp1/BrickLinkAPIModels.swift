
import Foundation



struct BrickLinkAPIResponse<T>: Decodable where T: Decodable {
    
    
    let data: T?
}



struct BrickLinkOrder: Decodable {
    
    
    let orderId: Int
    let dateOrdered: String
    let buyerName: String
    let totalCount: Int
    let uniqueCount: Int
    let status: String
}
