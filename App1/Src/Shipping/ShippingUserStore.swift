
import Foundation
import Core



@Observable
@MainActor
class ShippingUserStore {
    
    
    private let shippingCoreController: ShippingCoreController
    private let orderCoreController: OrderCoreController
    
    
    init(_ shippingCoreController: ShippingCoreController, _ orderCoreController: OrderCoreController) {
     
        self.shippingCoreController = shippingCoreController
        self.orderCoreController = orderCoreController
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderCoreController.orderDetails(forOrderWithId: orderId)
    }
    
    
    // MARK: - Shipping cost
    
    
    public func confirmedShippingCost(forOrderWithId orderId: OrderSummary.ID) -> Float? {
        
        shippingCoreController.confirmedShippingCost(forOrderWithId: orderId)
    }
    
    
    public func confirmShippingCost(forOrderWithId orderId: OrderSummary.ID, cost: Float) {
        
        shippingCoreController.confirmShippingCost(forOrderWithId: orderId, cost: cost)
    }
    
    
    public func selectedShippingCost(forOrderWithId orderId: OrderSummary.ID) -> SelectedShippingCost? {
        
        let order = orderDetails(forOrderWithId: orderId)!
        
        let weight = order.totalWeight * orderWeightMarginRatio
        
        if order.shippingMethodId == shippingMethodId_France_LaPoste {
            
            if let band = shippingCostBandsFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                    
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if order.shippingMethodId == shippingMethodId_Europe_LaPoste {
            
            if let band = shippingCostBandsEurope
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                  
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                        
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if order.shippingMethodId == shippingMethodId_World_LaPoste {
            
            if let band = shippingCostBandsWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                    
                var chooseLetter: Bool = false
                let chooseParcel: Bool = false
                var chooseParcelZB: Bool = false
                var chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    if ["US"].contains(order.shippingAddressCountryCode) {
                        chooseParcelZC = true
                        value = band.priceParcelZC
                    } else {
                        chooseParcelZB = true
                        value = band.priceParcelZB
                    }
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                        
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
        }
        
        return nil
    }
    
    
    // MARK: - Stamping
    
    
    public func confirmedStamping(forOrderWithId orderId: OrderSummary.ID) -> String? {
        
        shippingCoreController.confirmedStamping(forOrderWithId: orderId)
    }
    
    
    public func confirmStamping(forOrderWithId orderId: OrderSummary.ID, stamping: String) {
        
        shippingCoreController.confirmStamping(forOrderWithId: orderId, stamping: stamping)
    }
    
    
    public func dateOrderValidatedWithoutStamping(orderId: OrderDetails.ID) -> Date? {
        
        shippingCoreController.dateOrderValidatedWithoutStamping(orderId: orderId)
    }
    
    
    public func validateOrderWithoutStamping(orderId: OrderDetails.ID) {
        
        shippingCoreController.validateOrderWithoutStamping(orderId: orderId)
    }
    
    
    public func recommendedStampingMethod(forOrderWithId orderId: OrderSummary.ID) -> String {
        
        let selectedShippingCost = selectedShippingCost(forOrderWithId: orderId)
        let order = orderDetails(forOrderWithId: orderId)!
        
        var s = ""
        
        if let selectedLetterStamping = selectedShippingCost?.letterStamping {
            
            if selectedLetterStamping.usePostOffice {
                return "Bureau de poste"
            } else {
                s = "\(selectedLetterStamping.nbTimbres ?? 0) timbres"
                
                if order.shippingMethodId != shippingMethodId_France_LaPoste {
                    s += " international"
                }
                
                return s
            }
        }
        
        return s
    }
}
