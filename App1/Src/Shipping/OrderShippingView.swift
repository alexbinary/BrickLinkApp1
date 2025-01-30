
import SwiftUI



struct OrderShippingView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderDetails.ID
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
                
            if let order = appController.orderDetails(forOrderWithId: orderId) {
                
                HStack(alignment: .top, spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                
                        HeaderTitleView(label: "􂙡 Address")
                        
                        VStack(alignment: .leading) {
                            Text(order.shippingAddressName)
                            Text(order.shippingAddress).fixedSize(horizontal: false, vertical: true)
                            Text(order.shippingAddressCountryCode)
                        }
                        .font(.title3)
                        .padding(.horizontal)
                    }
                    .padding(8)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(nsColor: .tertiarySystemFill))
                    )
                    
                    Spacer()
                    
                    let width1: CGFloat = 90
                    let width2: CGFloat = 170
                    let height1: CGFloat = 20
                    let height2: CGFloat = 10
                    
                    Grid {
                        GridRow {
                            
                            InfoCardView(title: "􀭭 Weight") {
                                
                                Text("\(String(format: "%.0f", order.totalWeight))g")
                                    .bold()
                                    .frame(width: width1, height: height1)
                                
                            } detail: {
                                
                                Text("Charged \(String(format: "%.0f", order.totalWeight * orderWeightMarginRatio))g")
                                    .foregroundStyle(.secondary)
                                    .frame(width: width1, height: height2)
                            }
                            
                            InfoCardView(title: "􀖧 Shipping") {
                                
                                Text(order.shippingCost, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                    .bold()
                                    .frame(width: width2, height: height1)
                                
                            } detail: {
                                
                                Text(order.shippingMethodName ?? "")
                                    .foregroundStyle(.secondary)
                                    .frame(width: width2, height: height2)
                            }
                        }
                        
                        GridRow {
                            
                            InfoCardView(title: "􀐚 Packing") {
                                
                                if selectedShippingCost?.chooseLetter ?? false {
                                    
                                    Text("􀍖").font(.title2)
                                        .foregroundStyle(.secondary)
                                        .frame(width: width1, height: height1)
                                    
                                } else {
                                    
                                    Text("􀐛").font(.title2)
                                        .foregroundStyle(.secondary)
                                        .frame(width: width1, height: height1)
                                }
                                
                            } detail: {
                                
                                if selectedShippingCost?.chooseLetter ?? false {
                                    
                                    Text("Letter")
                                        .foregroundStyle(.secondary)
                                        .frame(width: width1, height: height2)
                                    
                                } else {
                                    
                                    Text("Parcel")
                                        .foregroundStyle(.secondary)
                                        .frame(width: width1, height: height2)
                                }
                            }

                            
                            InfoCardView(title: "􀖧 Cost") {
                                
                                if let shippingCostPredictedValue = selectedShippingCost?.value {
                                 
                                    Text(shippingCostPredictedValue, format: .currency(code: "EUR").presentation(.isoCode))
                                        .bold()
                                        .frame(width: width2, height: height1)
                                } else {
                                    Text("")
                                }
                                
                            } detail: {
                                
                                let recommendedStampingMethod = {
                                    
                                    var s = ""
                                    
                                    if let selectedLetterStamping = selectedShippingCost?.letterStamping {
                                        
                                        if selectedLetterStamping.usePostOffice {
                                            return "Bureau de poste"
                                        } else {
                                            s = "\(selectedLetterStamping.nbTimbres) timbres"
                                            
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
                        }
                    }
                    
                    Spacer()
                    
                    ShippingCostInfo(
                        shippingMethodId: order.shippingMethodId,
                        selectedShippingCost: selectedShippingCost
                    )
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .top)
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
                            
                            if let selectedLetterStamping = selectedShippingCost?.letterStamping {
                                
                                if selectedLetterStamping.usePostOffice {
                                    return "Bureau de poste"
                                } else {
                                    s = "\(selectedLetterStamping.nbTimbres) timbres"
                                    
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
                                    
                                    if let shippingCostPredictedValue = selectedShippingCost?.value {
                                        
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
                                
                                if let confirmedMethod = appController.stamping(forOrderWithId: order.id) {
                                    Text(confirmedMethod)
                                } else {
                                    Text("")
                                }
                                
                                HStack {
                                    Button {
                                        appController.updateStamping(forOrderWithId: order.id, method: recommendedStampingMethod)
                                    } label: {
                                        Text("Recommended: \(recommendedStampingMethod)")
                                    }
                                    
                                    if recommendedStampingMethod != "Bureau de poste" {
                                        Button {
                                            appController.updateStamping(forOrderWithId: order.id, method: "Bureau de poste")
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
            
            if let band = shippingCostBandsFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.tarifRef
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                    
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferTimbres,
                        usePostOffice: !priceLetter.preferTimbresParMultiples && !priceLetter.preferTimbres,
                        
                        nbTimbres: priceLetter.preferTimbres ? Int(ceil(priceLetter.nbTimbresRequired)) : priceLetter.preferTimbresParMultiples ? priceLetter.timbresParMultiples ?? 0 : 0
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if order.shippingMethodId == shippingMethodId_Europe {
            
            if let band = shippingCostBandsEurope
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                  
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.tarifRef
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                        
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferTimbres,
                        usePostOffice: !priceLetter.preferTimbresParMultiples && !priceLetter.preferTimbres,
                        
                        nbTimbres: priceLetter.preferTimbres ? Int(ceil(priceLetter.nbTimbresRequired)) : priceLetter.preferTimbresParMultiples ? priceLetter.timbresParMultiples ?? 0 : 0
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if order.shippingMethodId == shippingMethodId_World {
            
            if let band = shippingCostBandsWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                    
                var chooseLetter: Bool = false
                let chooseParcel: Bool = false
                var chooseParcelZB: Bool = false
                var chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.tarifRef
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
                        useTimbres: priceLetter.preferTimbres,
                        usePostOffice: !priceLetter.preferTimbresParMultiples && !priceLetter.preferTimbres,
                        
                        nbTimbres: priceLetter.preferTimbres ? Int(ceil(priceLetter.nbTimbresRequired)) : priceLetter.preferTimbresParMultiples ? priceLetter.timbresParMultiples ?? 0 : 0
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
        }
        
        return nil
    }
}



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
