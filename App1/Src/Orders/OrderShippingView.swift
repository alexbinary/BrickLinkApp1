
import SwiftUI



struct OrderShippingView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderDetails.ID
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
                
            if let order = appController.orderDetails(forOrderWithId: orderId) {
                
                HStack(alignment: .top, spacing: 48) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                
                        HeaderTitleView(label: "􂙡 Address")
                        
                        VStack(alignment: .leading) {
                            Text(order.shippingAddressName)
                            Text(order.shippingAddress).fixedSize(horizontal: false, vertical: true)
                            Text(order.shippingAddressCountryCode)
                        }
                        .font(.title3)
                    }
                    .padding(8)
                    
                    let width1: CGFloat = 90
                    let width2: CGFloat = 180
                    let height1: CGFloat = 20
                    let height2: CGFloat = 10
                    
                    Grid {
                        GridRow {
                     
                            VStack(alignment: .leading, spacing: 0) {
                                
                                HeaderTitleView(label: "􀭭 Weight")
                                
                                VStack(alignment: .center, spacing: 12) {
                                
                                    Text("\(String(format: "%.0f", order.totalWeight))g").font(.title3)
                                        .bold()
                                        .frame(width: width1, height: height1)
                                    Text("Charged \(String(format: "%.0f", order.totalWeight * orderWeightMarginRatio))g")
                                        .foregroundStyle(.secondary)
                                        .frame(width: width1, height: height2)
                                }
                                .monospacedDigit()
                                .padding()
                            }
                            .padding(8)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(nsColor: .tertiarySystemFill))
                            )
                            
                            VStack(alignment: .leading, spacing: 0) {
                                
                                HeaderTitleView(label: "􀖧 Shipping")
                                
                                VStack(alignment: .center, spacing: 12) {
                                
                                    Text(order.shippingCost, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                        .bold()
                                        .frame(width: width2, height: height1)
                                    Text(order.shippingMethodName ?? "")
                                        .foregroundStyle(.secondary)
                                        .frame(width: width2, height: height2)
                                }
                                .padding()
                            }
                            .padding(8)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(nsColor: .tertiarySystemFill))
                            )
                            
                        }
                        
                        GridRow {
                            
                            VStack(alignment: .leading, spacing: 0) {
                                
                                HeaderTitleView(label: "􀐚 Packing")
                                
                                VStack(alignment: .center, spacing: 12) {
                                
                                    if selectedShippingCost?.chooseLetter ?? false {
                                        
                                        Text("􀍖").font(.title2)
                                            .foregroundStyle(.secondary)
                                            .frame(width: width1, height: height1)
                                        Text("Letter")
                                            .foregroundStyle(.secondary)
                                            .frame(width: width1, height: height2)
                                        
                                    } else {
                                        
                                        Text("􀐛").font(.title2)
                                            .foregroundStyle(.secondary)
                                            .frame(width: width1, height: height1)
                                        Text("Parcel")
                                            .foregroundStyle(.secondary)
                                            .frame(width: width1, height: height2)
                                    }
                                }
                                .padding()
                            }
                            .padding(8)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(nsColor: .tertiarySystemFill))
                            )
                            
                            VStack(alignment: .leading, spacing: 0) {
                                
                                HeaderTitleView(label: "􀖧 Cost")
                                
                                VStack(alignment: .center, spacing: 12) {
                                
                                    if let selectedShippingCost = selectedShippingCost,
                                       let shippingCostPredictedValue = selectedShippingCost.value {
                                     
                                        Text(shippingCostPredictedValue, format: .currency(code: "EUR").presentation(.isoCode))
                                            .bold()
                                            .frame(width: width2, height: height1)
                                    }
                                    
                                    let recommendedStampingMethod = {
                                        
                                        var s = ""
                                        
                                        if let selectedAffranchissement = selectedAffranchissement {
                                            
                                            if selectedAffranchissement.usePostOffice {
                                                return "Bureau de poste"
                                            } else {
                                                s = "\(selectedAffranchissement.nbTimbres) timbres"
                                                
                                                if order.shippingMethodId != shippingMethodId_France {
                                                    s += " international"
                                                }
                                                
                                                return s
                                            }
                                        }
                                        
                                        return s
                                    }()
                                    
                                    Text(recommendedStampingMethod)
                                        .foregroundStyle(.secondary)
                                        .frame(width: width2, height: height2)
                                }
                                .padding()
                            }
                            .padding(8)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(nsColor: .tertiarySystemFill))
                            )
                            
                        }
                    }
                    
                    Spacer()
                    
                    ShippingCostInfo(
                        shippingMethodId: order.shippingMethodId,
                        selectedShippingCost: selectedShippingCost
                    )
                    .padding()
                    .background(Color(nsColor: .secondarySystemFill).opacity(0.7))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(nsColor: .tertiarySystemFill))
                    )
                }
                
                Divider()
                
                HStack(alignment: .top, spacing: 48) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􀐚 Packing & Stamping")
                        
                        let recommendedStampingMethod = {
                            
                            var s = ""
                            
                            if let selectedAffranchissement = selectedAffranchissement {
                                
                                if selectedAffranchissement.usePostOffice {
                                    return "Bureau de poste"
                                } else {
                                    s = "\(selectedAffranchissement.nbTimbres) timbres"
                                    
                                    if order.shippingMethodId != shippingMethodId_France {
                                        s += " international"
                                    }
                                    
                                    return s
                                }
                            }
                            
                            return s
                        }()
                        
                        Grid(alignment: .leading, verticalSpacing: 8) {
                            
                            GridRow {
                                Text("Shipping cost :")
                                
                                var shippingCostEditValue = appController.shippingCost(forOrderWithId: order.id) ?? 0
                                
                                let shippingCostBinding = Binding<Float> {
                                    return shippingCostEditValue
                                } set: { newValue in
                                    shippingCostEditValue = newValue
                                }
                                
                                TextField("Shipping cost", value: shippingCostBinding,
                                          format: .currency(code: "EUR").presentation(.isoCode)
                                )
                                .onSubmit {
                                    appController.updateShippingCost(forOrderWithId: order.id, cost: shippingCostEditValue)
                                }
                                .frame(maxWidth: 120)
                                
                                HStack {
                                    Button {
                                        Task {
                                            appController.updateShippingCost(forOrderWithId: order.id, cost: shippingCostEditValue)
                                        }
                                    } label: {
                                        Text("Save")
                                    }
                                    
                                    if let selectedShippingCost = selectedShippingCost,
                                       let shippingCostPredictedValue = selectedShippingCost.value {
                                        
                                        Button {
                                            appController.updateShippingCost(forOrderWithId: order.id, cost: shippingCostPredictedValue)
                                        } label: {
                                            HStack {
                                                Text("Predicted:")
                                                Text(shippingCostPredictedValue, format: .currency(code: "EUR").presentation(.isoCode))
                                            }
                                        }
                                    }
                                }
                            }
                            
                            GridRow {
                                Text("Stamping :")
                                
                                if let confirmedMethod = appController.affranchissement(forOrderWithId: order.id) {
                                    Text(confirmedMethod)
                                } else {
                                    Text("")
                                }
                                
                                HStack {
                                    Button {
                                        appController.updateAffranchissement(forOrderWithId: order.id, method: recommendedStampingMethod)
                                    } label: {
                                        Text("Recommended: \(recommendedStampingMethod)")
                                    }
                                    
                                    if recommendedStampingMethod != "Bureau de poste" {
                                        Button {
                                            appController.updateAffranchissement(forOrderWithId: order.id, method: "Bureau de poste")
                                        } label: {
                                            Text("Bureau de poste")
                                        }
                                    }
                                }
                            }
                            
                            GridRow {
                                Text("")
                                Text("")
                                HStack {
                                    Button {
                                        self.appController.validateOrderWithoutStamping(orderId: order.id)
                                    } label: {
                                        Text("Validate without stamping")
                                    }
                                    if let date = appController.dateOrderValidatedWithoutStamping(orderId: order.id) {
                                        Text("Validated without stamping on")
                                        Text(date, format: .dateTime)
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􁁾 Shipping")
                        
                        Grid(alignment: .leading, verticalSpacing: 8) {
                            
                            GridRow {
                                
                                Text("Tracking no :")
                                
                                var trackingNoEditValue = order.trackingNo
                                
                                let trackingNoBinding = Binding<String> {
                                    return trackingNoEditValue ?? ""
                                } set: { newValue in
                                    trackingNoEditValue = newValue
                                }
                                
                                TextField("Tracking No", text: trackingNoBinding)
                                    .onSubmit {
                                        Task {
                                            await appController.updateTrackingNo(forOrderWithId: order.id, trackingNo: trackingNoEditValue ?? "")
                                        }
                                    }
                                    .frame(maxWidth: 140)
                                
                                Button {
                                    Task {
                                        await appController.updateTrackingNo(forOrderWithId: order.id, trackingNo: trackingNoEditValue ?? "")
                                    }
                                } label: {
                                    Text("Save")
                                }
                            }
                            
                            GridRow {
                                
                                Text("Drive thru :")
                                
                                if order.driveThruSent {
                                    Text("sent")
                                } else {
                                    Text("not sent")
                                }
                                
                                Button {
                                    Task {
                                        await appController.sendDriveThru(orderId: order.id)
                                    }
                                } label: {
                                    Text("Send")
                                }
                            }
                            
                            Button {
                                Task {
                                    await appController.updateOrderStatus(orderId: order.id, status: .shipped)
                                    await appController.sendDriveThru(orderId: order.id)
                                }
                            } label: {
                                Text("Ship and send Drive thru")
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .task {
            await parallel([
                { await loadOrder() },
                { await loadOrderItems() },
            ])
        }
        .onChange(of: orderId) { oldValue, newValue in
            Task {
                await parallel([
                    { await loadOrder() },
                    { await loadOrderItems() },
                ])
            }
        }
    }
    
    
    func loadOrder() async {
        
        await appController.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
    
    
    func loadOrderItems() async {
        
        await appController.loadOrderItemsIfMissing(forOrderWithId: orderId)
    }
    
    
    var selectedShippingCost: SelectedShippingCost? {
        
        guard let order = appController.orderDetails(forOrderWithId: orderId) else {
            return nil
        }
        
        let weight = order.totalWeight * orderWeightMarginRatio
        
        if order.shippingMethodId == shippingMethodId_France {
            
            if let cost = shippingCostFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = cost.priceLetter
                } else {
                    chooseParcel = true
                    value = cost.priceParcel
                }
                
                return SelectedShippingCost(
                    maxWeight: cost.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    value: value
                )
            }
            
        } else if order.shippingMethodId == shippingMethodId_Europe {
            
            if let cost = shippingCostEurope
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = cost.priceLetter
                } else {
                    chooseParcel = true
                    value = cost.priceParcel
                }
                
                return SelectedShippingCost(
                    maxWeight: cost.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    value: value
                )
            }
            
        } else if order.shippingMethodId == shippingMethodId_World {
            
            if let cost = shippingCostWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                let chooseParcel: Bool = false
                var chooseParcelZB: Bool = false
                var chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = cost.priceLetter
                } else {
                    if ["US"].contains(order.shippingAddressCountryCode) {
                        chooseParcelZC = true
                        value = cost.priceParcelZC
                    } else {
                        chooseParcelZB = true
                        value = cost.priceParcelZB
                    }
                }
                
                return SelectedShippingCost(
                    maxWeight: cost.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    value: value
                )
            }
        }
        
        return nil
    }
    
    
    var selectedAffranchissement: SelectedAffranchissement? {
        
        guard let order = appController.orderDetails(forOrderWithId: orderId) else {
            return nil
        }
        
        let weight = order.totalWeight * orderWeightMarginRatio
        
        if order.shippingMethodId == shippingMethodId_France {
            
            if let aff = affranchissementValuesFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                return SelectedAffranchissement(
                    maxWeight: aff.maxWeight,
                    
                    useTimbresParMultiples: aff.preferTimbresParMultiples,
                    useTimbres: aff.preferTimbres,
                    usePostOffice: !aff.preferTimbresParMultiples && !aff.preferTimbres,
                    
                    nbTimbres: aff.preferTimbres ? Int(ceil(aff.nbTimbresRequired)) : aff.preferTimbresParMultiples ? aff.timbresParMultiples ?? 0 : 0
                )
            }
            
        } else {
            
            if let aff = affranchissementValuesWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                return SelectedAffranchissement(
                    maxWeight: aff.maxWeight,
                    
                    useTimbresParMultiples: aff.preferTimbresParMultiples,
                    useTimbres: aff.preferTimbres,
                    usePostOffice: !aff.preferTimbresParMultiples && !aff.preferTimbres,
                    
                    nbTimbres: aff.preferTimbres ? Int(ceil(aff.nbTimbresRequired)) : aff.preferTimbresParMultiples ? aff.timbresParMultiples ?? 0 : 0
                )
            }
        }
        
        return nil
    }
}



struct ShippingCostTableRow: Identifiable {
    
    var id: Int { maxWeight }
    let minWeight: Int
    let maxWeight: Int
    let priceLetter: Float?
    var priceParcel: Float? = nil
    var priceParcelZB: Float? = nil
    var priceParcelZC: Float? = nil
}


struct SelectedShippingCost {
    
    let maxWeight: Int
    var chooseLetter: Bool = false
    var chooseParcel: Bool = false
    var chooseParcelZB: Bool = false
    var chooseParcelZC: Bool = false
    let value: Float?
}



let shippingMethodId_France = 289751
let shippingMethodId_Europe = 290360
let shippingMethodId_World = 185519


let shippingCostFrance = [
    
    ShippingCostTableRow(
        minWeight: 0, maxWeight: 20,
        priceLetter: 1.89, priceParcel: 5.25
    ),
    ShippingCostTableRow(
        minWeight: 20, maxWeight: 100,
        priceLetter: 3.28, priceParcel: 5.25
    ),
    ShippingCostTableRow(
        minWeight: 100, maxWeight: 250,
        priceLetter: 5.22, priceParcel: 5.25
    ),
    ShippingCostTableRow(
        minWeight: 250, maxWeight: 500,
        priceLetter: 7.20, priceParcel: 7.35
    ),
    ShippingCostTableRow(
        minWeight: 500, maxWeight: 750,
        priceLetter: 8.90, priceParcel: 8.65
    ),
    ShippingCostTableRow(
        minWeight: 750, maxWeight: 1000,
        priceLetter: 8.90, priceParcel: 9.40
    ),
    ShippingCostTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceLetter: 10.75, priceParcel: 10.70
    ),
    ShippingCostTableRow(
        minWeight: 2000, maxWeight: 5000,
        priceLetter: nil, priceParcel: 16.60
    ),
]

let shippingCostEurope = [
    
    ShippingCostTableRow(
        minWeight: 0, maxWeight: 20,
        priceLetter: 4.90, priceParcel: 14.85
    ),
    ShippingCostTableRow(
        minWeight: 20, maxWeight: 100,
        priceLetter: 7.30, priceParcel: 14.85
    ),
    ShippingCostTableRow(
        minWeight: 100, maxWeight: 250,
        priceLetter: 13.60, priceParcel: 14.85
    ),
    ShippingCostTableRow(
        minWeight: 250, maxWeight: 500,
        priceLetter: 18.30, priceParcel: 14.85
    ),
    ShippingCostTableRow(
        minWeight: 500, maxWeight: 750,
        priceLetter: 32.30, priceParcel: 18.45
    ),
    ShippingCostTableRow(
        minWeight: 750, maxWeight: 1000,
        priceLetter: 32.30, priceParcel: 18.45
    ),
    ShippingCostTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceLetter: 32.30, priceParcel: 20.90
    ),
    ShippingCostTableRow(
        minWeight: 2000, maxWeight: 5000,
        priceLetter: nil, priceParcel: 26.80
    ),
]

let shippingCostWorld = [
    
    ShippingCostTableRow(
        minWeight: 0, maxWeight: 20,
        priceLetter: 4.90, priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostTableRow(
        minWeight: 20, maxWeight: 100,
        priceLetter: 7.30, priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostTableRow(
        minWeight: 100, maxWeight: 250,
        priceLetter: 13.60, priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostTableRow(
        minWeight: 250, maxWeight: 500,
        priceLetter: 18.30, priceParcelZB: 22.70, priceParcelZC: 33.50
    ),
    ShippingCostTableRow(
        minWeight: 500, maxWeight: 750,
        priceLetter: 32.30, priceParcelZB: 27.10, priceParcelZC: 37.30
    ),
    ShippingCostTableRow(
        minWeight: 750, maxWeight: 1000,
        priceLetter: 32.30, priceParcelZB: 29.65, priceParcelZC: 51.40
    ),
    ShippingCostTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceLetter: 32.30, priceParcelZB: 29.65, priceParcelZC: 51.40
    ),
    ShippingCostTableRow(
        minWeight: 2000, maxWeight: 5000,
        priceLetter: nil, priceParcelZB: 38.00, priceParcelZC: 75.00
    ),
]


struct AffranchissementTableRow: Identifiable {
    
    var id: Int { maxWeight }
    
    let minWeight: Int
    let maxWeight: Int
    
    let priceTimbre: Float
    let priceTracking: Float
    
    let tarifRef: Float
    
    let timbresParMultiples: Int?
    var timbresParMultiplesTotalPrice: Float? {
        guard let n = self.timbresParMultiples else { return nil }
        return Float(n) * priceTimbre + priceTracking
    }
    
    var nbTimbresRequired: Float {
        (self.tarifRef - priceTracking)/priceTimbre
    }
    var nbTimbresRequiredTotalPrice: Float {
        ceilf(nbTimbresRequired) * priceTimbre + priceTracking
    }
    
    var preferTimbresParMultiples: Bool {
        timbresParMultiplesTotalPrice != nil && timbresParMultiplesTotalPrice! <= tarifRef
    }
    var preferTimbres: Bool {
        nbTimbresRequiredTotalPrice <= tarifRef
    }
}


struct SelectedAffranchissement {
    
    let maxWeight: Int
    
    let useTimbresParMultiples: Bool
    let useTimbres: Bool
    let usePostOffice: Bool
    
    let nbTimbres: Int
}


let priceTimbreFrance: Float = 1.39
let priceTrackingFrance: Float = 0.50

let priceTimbreWorld: Float = 2.10
let priceTrackingWorld: Float = 2.80


let affranchissementValuesFrance = [

    AffranchissementTableRow(
        minWeight: 0, maxWeight: 20,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 1.89, timbresParMultiples: 1
    ),
    AffranchissementTableRow(
        minWeight: 20, maxWeight: 100,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 3.28, timbresParMultiples: 2
    ),
    AffranchissementTableRow(
        minWeight: 100, maxWeight: 250,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 5.22, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 250, maxWeight: 500,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 7.20, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 500, maxWeight: 750,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 8.90, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 750, maxWeight: 1000,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 8.90, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 10.75, timbresParMultiples: nil
    ),
]

let affranchissementValuesWorld = [

    AffranchissementTableRow(
        minWeight: 0, maxWeight: 20,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 4.90, timbresParMultiples: 1
    ),
    AffranchissementTableRow(
        minWeight: 20, maxWeight: 100,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 7.30, timbresParMultiples: 2
    ),
    AffranchissementTableRow(
        minWeight: 100, maxWeight: 250,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 13.60, timbresParMultiples: 5
    ),
    AffranchissementTableRow(
        minWeight: 250, maxWeight: 500,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 18.30, timbresParMultiples: 8
    ),
    AffranchissementTableRow(
        minWeight: 500, maxWeight: 750,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 32.30, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 750, maxWeight: 1000,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 32.30, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 32.30, timbresParMultiples: nil
    ),
]


#Preview {
    
    let dataFileUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath.appending("/data/data.json5"))
    let dataStore = DataStore(dataFileUrl: dataFileUrl)
    
    let blCredentials = BrickLinkAPICredentials(
        
        consumerKey: Secrets.BrickLink.consumerKey,
        consumerSecret: Secrets.BrickLink.consumerSecret,
        
        tokenValue: Secrets.BrickLink.tokenValue,
        tokenSecret: Secrets.BrickLink.tokenSecret
    )
    
    let appController = AppController(
        dataStore: dataStore, blCredentials: blCredentials
    )
    
    OrderShippingView(orderId: "27236825")
        .environmentObject(appController)
}
