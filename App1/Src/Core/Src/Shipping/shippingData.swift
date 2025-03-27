
import Foundation



public struct ShippingCostBand: Identifiable, Sendable {
    
    public var id: Int { maxWeight }
    
    public let minWeight: Int
    public let maxWeight: Int
    
    public let letter: LetterCost?
    
    public var priceParcel: Decimal? = nil
    public var priceParcelZB: Decimal? = nil
    public var priceParcelZC: Decimal? = nil
}


public struct LetterCost: Sendable {
    
    public let refPrice: Decimal
    
    public let priceTimbre: Decimal
    public let priceTracking: Decimal
    
    
    public var minNbTimbresToCoverRefPrice: Int {
        let raw = (self.refPrice - priceTracking)/priceTimbre
        return Int(ceilf(NSDecimalNumber(decimal: raw).floatValue))
    }
    public var priceTimbresToCoverRefPrice: Decimal {
        Decimal(minNbTimbresToCoverRefPrice) * priceTimbre + priceTracking
    }
    
    
    public let timbresParMultiples: Int?
    
    public var priceTimbresParMultiples: Decimal? {
        if let n = self.timbresParMultiples {
            return Decimal(n) * priceTimbre + priceTracking
        } else {
            return nil
        }
    }
    
    
    public var preferTimbresParMultiples: Bool {
        if let n = priceTimbresParMultiples {
            return n < refPrice
        } else {
            return false
        }
    }
    public var preferCoverRefPriceWithTimbres: Bool {
        priceTimbresToCoverRefPrice <= refPrice
    }
    public var preferPostOffice: Bool {
        !preferTimbresParMultiples && !preferCoverRefPriceWithTimbres
    }

    public var bestPrice: Decimal {
        if preferTimbresParMultiples, let p = priceTimbresParMultiples {
            return p
        }
        if preferCoverRefPriceWithTimbres {
            return priceTimbresToCoverRefPrice
        }
        return refPrice
    }
    public var nbTimbres: Int? {
        if preferTimbresParMultiples, let n = timbresParMultiples {
            return n
        }
        if preferCoverRefPriceWithTimbres {
            return minNbTimbresToCoverRefPrice
        }
        return nil
    }
}



public struct SelectedShippingCost {
    
    public let maxWeight: Int
    
    public var preferLetter: Bool
    public var preferParcel: Bool
    public var preferParcelZB: Bool
    public var preferParcelZC: Bool
    
    public let letterStamping: LetterStamping?
    
    public let value: Decimal?
    
    
    public init(maxWeight: Int, preferLetter: Bool = false, preferParcel: Bool = false, preferParcelZB: Bool = false, preferParcelZC: Bool = false, letterStamping: LetterStamping?, value: Decimal?) {
        self.maxWeight = maxWeight
        self.preferLetter = preferLetter
        self.preferParcel = preferParcel
        self.preferParcelZB = preferParcelZB
        self.preferParcelZC = preferParcelZC
        self.letterStamping = letterStamping
        self.value = value
    }
}


public struct LetterStamping {
    
    public let useTimbresParMultiples: Bool
    public let useTimbres: Bool
    public let usePostOffice: Bool
    
    public let nbTimbres: Int?
    
    public init(useTimbresParMultiples: Bool, useTimbres: Bool, usePostOffice: Bool, nbTimbres: Int?) {
        self.useTimbresParMultiples = useTimbresParMultiples
        self.useTimbres = useTimbres
        self.usePostOffice = usePostOffice
        self.nbTimbres = nbTimbres
    }
}



public let shippingMethodId_France_LaPoste = 289751
public let shippingMethodId_France_MondialRelay = 330666
public let shippingMethodId_Europe_LaPoste = 290360
public let shippingMethodId_World_LaPoste = 185519

public let shippingMethodIds_LaPoste = [
    shippingMethodId_France_LaPoste,
    shippingMethodId_Europe_LaPoste,
    shippingMethodId_World_LaPoste,
]
public let shippingMethodIds_MondialRelay = [
    shippingMethodId_France_MondialRelay,
]

public let shippingMethodIds_France = [
    shippingMethodId_France_LaPoste,
    shippingMethodId_France_MondialRelay,
]


public let priceTimbreFrance: Decimal = 1.39
public let priceTrackingFrance: Decimal = 0.50

public let priceTimbreWorld: Decimal = 2.10
public let priceTrackingWorld: Decimal = 2.80


public let shippingCostBandsFrance = [
    
    ShippingCostBand(
        minWeight: 0,
        maxWeight: 20,
        letter: LetterCost(
            refPrice: 1.89,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: 1
        ),
        priceParcel: 5.25
    ),
    ShippingCostBand(
        minWeight: 20,
        maxWeight: 100,
        letter: LetterCost(
            refPrice: 3.28,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: 2
        ),
        priceParcel: 5.25
    ),
    ShippingCostBand(
        minWeight: 100,
        maxWeight: 250,
        letter: LetterCost(
            refPrice: 5.22,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 5.25
    ),
    ShippingCostBand(
        minWeight: 250,
        maxWeight: 500,
        letter: LetterCost(
            refPrice: 7.20,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 7.35
    ),
    ShippingCostBand(
        minWeight: 500,
        maxWeight: 750,
        letter: LetterCost(
            refPrice: 8.90,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 8.65
    ),
    ShippingCostBand(
        minWeight: 750,
        maxWeight: 1000,
        letter: LetterCost(
            refPrice: 8.90,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 9.40
    ),
    ShippingCostBand(
        minWeight: 1000,
        maxWeight: 2000,
        letter: LetterCost(
            refPrice: 10.75,
            priceTimbre: priceTimbreFrance,
            priceTracking: priceTrackingFrance,
            timbresParMultiples: nil
        ),
        priceParcel: 10.70
    ),
    ShippingCostBand(
        minWeight: 2000,
        maxWeight: 5000,
        letter: nil,
        priceParcel: 16.60
    )
]


public let shippingCostBandsEurope = [
    
    ShippingCostBand(
        minWeight: 0,
        maxWeight: 20,
        letter: LetterCost(
            refPrice: 4.90,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 1
        ),
        priceParcel: 14.85
    ),
    ShippingCostBand(
        minWeight: 20,
        maxWeight: 100,
        letter: LetterCost(
            refPrice: 7.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 2
        ),
        priceParcel: 14.85
    ),
    ShippingCostBand(
        minWeight: 100,
        maxWeight: 250,
        letter: LetterCost(
            refPrice: 13.60,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 5
        ),
        priceParcel: 14.85
    ),
    ShippingCostBand(
        minWeight: 250,
        maxWeight: 500,
        letter: LetterCost(
            refPrice: 18.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 8
        ),
        priceParcel: 14.85
    ),
    ShippingCostBand(
        minWeight: 500,
        maxWeight: 750,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcel: 18.45
    ),
    ShippingCostBand(
        minWeight: 750,
        maxWeight: 1000,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcel: 18.45
    ),
    ShippingCostBand(
        minWeight: 1000,
        maxWeight: 2000,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcel: 20.90
    ),
    ShippingCostBand(
        minWeight: 2000,
        maxWeight: 5000,
        letter: nil,
        priceParcel: 26.80
    ),
]


public let shippingCostBandsWorld = [
    
    ShippingCostBand(
        minWeight: 0,
        maxWeight: 20,
        letter: LetterCost(
            refPrice: 4.90,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 1
        ),
        priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostBand(
        minWeight: 20,
        maxWeight: 100,
        letter: LetterCost(
            refPrice: 7.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 2
        ),
        priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostBand(
        minWeight: 100,
        maxWeight: 250,
        letter: LetterCost(
            refPrice: 13.60,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 5
        ),
        priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostBand(
        minWeight: 250,
        maxWeight: 500,
        letter: LetterCost(
            refPrice: 18.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: 8
        ),
        priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostBand(
        minWeight: 500,
        maxWeight: 750,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcelZB: 27.10, priceParcelZC: 37.30
    ),
    ShippingCostBand(
        minWeight: 750,
        maxWeight: 1000,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcelZB: 29.65, priceParcelZC: 51.40
    ),
    ShippingCostBand(
        minWeight: 1000,
        maxWeight: 2000,
        letter: LetterCost(
            refPrice: 32.30,
            priceTimbre: priceTimbreWorld,
            priceTracking: priceTrackingWorld,
            timbresParMultiples: nil
        ),
        priceParcelZB: 29.65, priceParcelZC: 51.40
    ),
    ShippingCostBand(
        minWeight: 2000,
        maxWeight: 5000,
        letter: nil,
        priceParcelZB: 38.00, priceParcelZC: 75.00
    ),
]



public let orderWeightMarginRatio: Float = 1.2
