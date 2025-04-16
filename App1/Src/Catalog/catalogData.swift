
import SwiftUI



struct PartData {

    let ref: String
    
    var lengthAnnotation: String? = nil
    var lengthAnnotationPosition: Alignment = .bottomTrailing
    
    var dimensionsAnnotation: String? = nil
    var dimensionsAnnotationPosition: Alignment = .bottomTrailing
    
    var chiralityAnnotation: Chirality? = nil
    var chiralityAnnotationPosition: Alignment = .topLeading
}


enum Chirality: String {
    
    case left
    case right
}



let partData: [PartData] = [

    .init(
        ref: "29119",
        chiralityAnnotation: .right,
        chiralityAnnotationPosition: .topTrailing
    ),
    .init(
        ref: "41769",
        chiralityAnnotation: .right
    ),
    .init(
        ref: "2450", 
        lengthAnnotation: "3"
    ),
    .init(
        ref: "3020",
        lengthAnnotation: "4"
    ),
    .init(
        ref: "3021",
        lengthAnnotation: "3"
    ),
    .init(
        ref: "3029",
        dimensionsAnnotation: "4 x 12"
    ),
    .init(
        ref: "3068",
        lengthAnnotation: "2"
    ),
    .init(
        ref: "3623",
        lengthAnnotation: "3"
    ),
    .init(
        ref: "3666",
        lengthAnnotation: "6"
    ),
    .init(
        ref: "3705",
        lengthAnnotation: "4"
    ),
    .init(
        ref: "3709b",
        lengthAnnotation: "4"
    ),
    .init(
        ref: "3795",
        lengthAnnotation: "6"
    ),
    .init(
        ref: "3832",
        lengthAnnotation: "10"
    ),
    .init(
        ref: "6179",
        lengthAnnotation: "4"
    ),
    .init(
        ref: "11212",
        lengthAnnotation: "3"
    ),
    .init(
        ref: "11213",
        lengthAnnotation: "6"
    ),
    .init(
        ref: "26603",
        lengthAnnotation: "3"
    ),
    .init(
        ref: "30503",
        lengthAnnotation: "4"
    ),
    .init(
        ref: "32062",
        lengthAnnotation: "2"
    ),
    .init(
        ref: "37352",
        lengthAnnotation: "2"
    ),
    .init(
        ref: "41769",
        lengthAnnotation: "4"
    ),
    .init(
        ref: "43722",
        lengthAnnotation: "3"
    ),
    .init(
        ref: "98138",
        lengthAnnotation: "1"
    ),
]
