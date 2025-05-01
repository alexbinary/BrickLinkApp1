
import SwiftUI



func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
    
    CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}
