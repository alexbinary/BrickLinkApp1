
import Foundation
import Core



@MainActor
public func createEnv() -> Env {
    
    createEnv(brickLinkCredentials: Secrets.brickLinkAPICredentials, debug: Debug(printRequest: Secrets.Network.printRequest, printResponse: Secrets.Network.printResponse))
}
