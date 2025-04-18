
import Foundation



@MainActor
protocol ShippingStoreProtocol {
      
    func confirmedShippingCost(for order: Order) -> Float?
    func confirmShippingCost(for order: Order, cost: Float)
    func selectedShippingCost(for order: Order) -> SelectedShippingCost?
    
    func confirmedStamping(for order: Order) -> String?
    func confirmStamping(for order: Order, stamping: String)
    
    func dateOrderValidatedWithoutStamping(_ order: Order) -> Date?
    func validateOrderWithoutStamping(_ order: Order)
  
    func recommendedStampingMethod(for order: Order) -> String
}



@Observable
@MainActor
class ShippingStore: ShippingStoreProtocol {
    
    
    private let shippingController: ShippingController
    private let orderController: OrderController
    
    
    init(
        _ shippingController: ShippingController,
        _ orderController: OrderController
    ) {
        self.shippingController = shippingController
        self.orderController = orderController
    }
    
    
    private func details(for order: Order) -> OrderDetails? {
        
        orderController.details(for: order)
    }
    
    
    // MARK: - Shipping cost
    
    
    func confirmedShippingCost(for order: Order) -> Float? {
        
        shippingController.confirmedShippingCost(for: order)
    }
    
    
    func confirmShippingCost(for order: Order, cost: Float) {
        
        shippingController.confirmShippingCost(for: order, cost: cost)
    }
    
    
    func selectedShippingCost(for order: Order) -> SelectedShippingCost? {
        
        guard let orderDetails = details(for: order) else { return nil }
        
        let weight = orderDetails.totalWeight * orderWeightMarginRatio
        
        if orderDetails.shippingMethodId == shippingMethodId_France_LaPoste {
            
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
            
        } else if orderDetails.shippingMethodId == shippingMethodId_Europe_LaPoste {
            
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
            
        } else if orderDetails.shippingMethodId == shippingMethodId_World_LaPoste {
            
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
                    if ["US"].contains(orderDetails.shippingAddressCountryCode) {
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
    
    
    func confirmedStamping(for order: Order) -> String? {
        
        shippingController.confirmedStamping(for: order)
    }
    
    
    func confirmStamping(for order: Order, stamping: String) {
        
        shippingController.confirmStamping(for: order, stamping: stamping)
    }
    
    
    func dateOrderValidatedWithoutStamping(_ order: Order) -> Date? {
        
        shippingController.dateOrderValidatedWithoutStamping(order)
    }
    
    
    func validateOrderWithoutStamping(_ order: Order) {
        
        shippingController.validateOrderWithoutStamping(order)
    }
    
    
    func recommendedStampingMethod(for order: Order) -> String {
        
        let selectedShippingCost = selectedShippingCost(for: order)

        var s = ""
        
        if let selectedLetterStamping = selectedShippingCost?.letterStamping {
            
            if selectedLetterStamping.usePostOffice {
                
                return "Bureau de poste"
                
            } else if let orderDetails = details(for: order) {
                
                s = "\(selectedLetterStamping.nbTimbres ?? 0) timbres"
                
                if !orderDetails.shipsToFrance {
                    s += " international"
                }
                
                return s
            }
        }
        
        return s
    }
}
