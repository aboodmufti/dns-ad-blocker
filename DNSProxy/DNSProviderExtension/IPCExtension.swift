import Foundation
import Network

class IPCConnection: NSObject {

  var listener: NSXPCListener?
  var currentConnection: NSXPCConnection?
  weak var delegate: ProviderCommunication?
  static let shared = IPCConnection()

  var appProxy: AppCommunication? {
    guard let connection = currentConnection else {
      log.error("Failed to communicate with app because app is not registered")
      return nil
    }

    guard let appProxy = connection.remoteObjectProxyWithErrorHandler({ error in
      log.error("Failed to communicate with app: \(error.localizedDescription)")
//      self.currentConnection = nil
    }) as? AppCommunication else {
      log.error("Failed to create a remote object proxy for the app")
      return nil
    }

    return appProxy
  }

  private func extensionMachServiceName(from bundle: Bundle) -> String? {

    guard let networkExtensionKeys = bundle.object(forInfoDictionaryKey: "NetworkExtension") as? [String: Any],
          let machServiceName = networkExtensionKeys["NEMachServiceName"] as? String else {
            log.error("Mach service name is missing from the Info.plist")
            return nil
          }

    return machServiceName
  }

  func startListener() {
    guard let machServiceName = extensionMachServiceName(from: Bundle.main) else {
      log.error("Failed to start IPC listener")
      return
    }

    log.info("Starting XPC listener for mach service \(machServiceName)")

    let newListener = NSXPCListener(machServiceName: machServiceName)
    newListener.delegate = self
    newListener.resume()
    listener = newListener
  }

  func stop() {
    log.info("Stop IPC Connection")
    currentConnection?.invalidate()
    currentConnection = nil
  }
}


extension IPCConnection: NSXPCListenerDelegate {

  // MARK: NSXPCListenerDelegate

  func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
    log.info("Listener: new connection")

    newConnection.exportedInterface = NSXPCInterface(with: ProviderCommunication.self)
    newConnection.exportedObject = self

    newConnection.remoteObjectInterface = NSXPCInterface(with: AppCommunication.self)

    newConnection.invalidationHandler = {
      log.info("Invalidating IPC connection")
      self.currentConnection = nil
    }

    newConnection.interruptionHandler = {
      log.info("Interrupting IPC connection")
      self.currentConnection = nil
    }

    log.info("Resuming IPC connection")
    currentConnection = newConnection
    newConnection.resume()

    return true
  }
}


extension IPCConnection: ProviderCommunication {

  func getDomains() {
    let urls = UserDefaults.standard.array(forKey: StoreKey.blockListsURLs.rawValue) as? [String] ?? []

    blockedDomains = Trie()
    for url in urls {
      Networking.downloadFile(from: url)
    }
  }

  func updatedBlockLists(urls: [String]) {
    log.info("Updating blocklists: \(urls)")
    UserDefaults.standard.set(urls, forKey: StoreKey.blockListsURLs.rawValue)
    getDomains()
  }

  func register(_ completionHandler: @escaping (Bool) -> Void) {
    log.info("App registered")
    completionHandler(true)
  }
}
