/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 This file contains the implementation of the app <-> provider IPC connection
 */

import Foundation
import Network

/// App --> Provider IPC
@objc protocol ProviderCommunication {

  func register(_ completionHandler: @escaping (Bool) -> Void)
  func updatedBlockLists(urls: [String])

}

/// Provider --> App IPC
@objc protocol AppCommunication {

  func dnsProxyBlockedRequest()
  func getBlockLists(_ completion: @escaping ([String]) -> Void)
}

