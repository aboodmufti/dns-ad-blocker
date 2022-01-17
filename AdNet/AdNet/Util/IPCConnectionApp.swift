import Foundation
import Network

class IPCConnection: NSObject {

  var currentConnection: NSXPCConnection?
  weak var delegate: AppCommunication?
  static let shared = IPCConnection()


  private func extensionMachServiceName(from bundle: Bundle) -> String? {

    guard let networkExtensionKeys = bundle.object(forInfoDictionaryKey: "NetworkExtension") as? [String: Any],
          let machServiceName = networkExtensionKeys["NEMachServiceName"] as? String else {
            log.error("Mach service name is missing from the Info.plist")
            return nil
          }

    return machServiceName
  }

  func register(withExtension bundle: Bundle, delegate: AppCommunication, completionHandler: @escaping (Bool) -> Void) {

    self.delegate = delegate
    
//    guard currentConnection == nil else {
//      log.error("Already registered with the provider")
//      completionHandler(true)
//      return
//    }

    guard let machServiceName = extensionMachServiceName(from: bundle) else {
      log.error("Failed to register with extension")
      return
    }
    let newConnection = NSXPCConnection(machServiceName: machServiceName, options: [])

    newConnection.exportedInterface = NSXPCInterface(with: AppCommunication.self)
    newConnection.exportedObject = delegate

    newConnection.remoteObjectInterface = NSXPCInterface(with: ProviderCommunication.self)

    currentConnection = newConnection
    newConnection.resume()

    guard let providerProxy = newConnection.remoteObjectProxyWithErrorHandler({ registerError in
      log.error("Failed to register with the provider(\(machServiceName)): \(registerError.localizedDescription)")
      self.currentConnection?.invalidate()
      self.currentConnection = nil
      completionHandler(false)
    }) as? ProviderCommunication else {
      log.error("Failed to create a remote object proxy for the provider")
      return
    }

    log.info("Successfuly registered with provider")
    providerProxy.register(completionHandler)
  }

  func stop() {
    log.info("Stopping IPC Connection")
    currentConnection?.invalidate()
    currentConnection = nil
  }

  func blockListsUpdated(urls: [String]) -> Bool {
    guard let connection = currentConnection else {
      log.error("Failed to communicate with provider because app is not registered")
      return false
    }

    guard let providerProxy = connection.remoteObjectProxyWithErrorHandler({ error in
      log.error("Failed to communicate with provider: \(error.localizedDescription)")
//      self.currentConnection = nil
    }) as? ProviderCommunication else {
      log.error("Failed to create a remote object proxy for the extension")
      return false
    }

    log.info("Successfuly sent new lists to provider")
    providerProxy.updatedBlockLists(urls: urls)

    return true
  }
}
