
import SwiftUI



struct PartData {

    let ref: String
    var colorId: String? = nil
    
    func matches(ref: String) -> Bool {
        self.ref == ref
    }
    func matches(ref: String, colorId: String) -> Bool {
        self.ref == ref && self.colorId == colorId
    }
    
    var lengthAnnotation: String? = nil
    var lengthAnnotationPosition: Alignment = .bottomTrailing
    
    var dimensionsAnnotation: String? = nil
    var dimensionsAnnotationPosition: Alignment = .bottomTrailing
    
    var chiralityAnnotation: Chirality? = nil
    var chiralityAnnotationPosition: Alignment = .topLeading
    
    var variantAnnotation: Bool = false
    var variantAnnotationPosition: Alignment = .topLeading
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
        ref: "43723",
        chiralityAnnotation: .left
    ),
    .init(
        ref: "43722",
        chiralityAnnotation: .right
    ),
    .init(
        ref: "43721",
        chiralityAnnotation: .left
    ),
    .init(
        ref: "43720",
        chiralityAnnotation: .right
    ),
    .init(
        ref: "30355",
        chiralityAnnotation: .left
    ),
    .init(
        ref: "30356",
        chiralityAnnotation: .right
    ),
    .init(
        ref: "50304",
        chiralityAnnotation: .right,
        chiralityAnnotationPosition: .topTrailing
    ),
    .init(
        ref: "50304", colorId: "4",
        chiralityAnnotation: .right,
        chiralityAnnotationPosition: .bottomTrailing
    ),
    .init(
        ref: "2450", 
        lengthAnnotation: "3L"
    ),
    .init(
        ref: "3020",
        lengthAnnotation: "4L"
    ),
    .init(
        ref: "3021",
        lengthAnnotation: "3L"
    ),
    .init(
        ref: "3029",
        dimensionsAnnotation: "4 x 12"
    ),
    .init(
        ref: "3036",
        dimensionsAnnotation: "6 x 8"
    ),
    .init(
        ref: "3035",
        dimensionsAnnotation: "4 x 8"
    ),
    .init(
        ref: "3032",
        dimensionsAnnotation: "4 x 6"
    ),
    .init(
        ref: "3068",
        lengthAnnotation: "2L"
    ),
    .init(
        ref: "3623",
        lengthAnnotation: "3L"
    ),
    .init(
        ref: "3666",
        lengthAnnotation: "6L"
    ),
    .init(
        ref: "3705",
        lengthAnnotation: "4L"
    ),
    .init(
        ref: "3709b",
        lengthAnnotation: "4L"
    ),
    .init(
        ref: "3795",
        lengthAnnotation: "6L"
    ),
    .init(
        ref: "3832",
        lengthAnnotation: "10L"
    ),
    .init(
        ref: "6179",
        lengthAnnotation: "4L"
    ),
    .init(
        ref: "11212",
        lengthAnnotation: "3L"
    ),
    .init(
        ref: "11213",
        lengthAnnotation: "6L"
    ),
    .init(
        ref: "26603",
        lengthAnnotation: "3L"
    ),
    .init(
        ref: "30503",
        dimensionsAnnotation: "4 x 4"
    ),
    .init(
        ref: "32062",
        lengthAnnotation: "2L"
    ),
    .init(
        ref: "37352",
        lengthAnnotation: "2L"
    ),
    .init(
        ref: "41769",
        lengthAnnotation: "4L"
    ),
    .init(
        ref: "43722",
        lengthAnnotation: "3L"
    ),
    .init(
        ref: "3957",
        variantAnnotation: true
    ),
    .init(
        ref: "3957b",
        variantAnnotation: true
    ),
    .init(
        ref: "85080",
        variantAnnotation: true,
        variantAnnotationPosition: .bottomLeading
    ),
    .init(
        ref: "4599b",
        variantAnnotation: true,
        variantAnnotationPosition: .bottomLeading
    ),
    .init(
        ref: "4599b", colorId: "3",
        variantAnnotation: true,
        variantAnnotationPosition: .bottomTrailing
    ),
    .init(
        ref: "4599b", colorId: "1",
        variantAnnotation: true,
        variantAnnotationPosition: .bottomTrailing
    ),
    .init(
        ref: "87994",
        lengthAnnotation: "3L"
    ),
    .init(
        ref: "30374",
        lengthAnnotation: "4L"
    ),
    .init(
        ref: "3707",
        lengthAnnotation: "8L"
    ),
    .init(
        ref: "60485",
        lengthAnnotation: "9L"
    ),
    .init(
        ref: "3737",
        lengthAnnotation: "10L"
    ),
    .init(
        ref: "6112",
        lengthAnnotation: "12L"
    ),
    .init(
        ref: "3006",
        lengthAnnotation: "10L"
    ),
    .init(
        ref: "x127c10pb01",
        lengthAnnotation: "10L",
        lengthAnnotationPosition: .topLeading
    ),
    .init(
        ref: "78c06",
        lengthAnnotation: "6L",
        lengthAnnotationPosition: .topTrailing
    ),
    .init(
        ref: "78c12",
        lengthAnnotation: "12L"
    ),
    .init(
        ref: "78c09",
        lengthAnnotation: "9L"
    ),
    .init(
        ref: "60479",
        lengthAnnotation: "12L"
    ),
    .init(
        ref: "3747b",
        variantAnnotation: true
    ),
]
