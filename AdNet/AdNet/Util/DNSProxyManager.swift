import Foundation
import NetworkExtension
import SystemExtensions
import SwiftUI

protocol DNSProxyManagerDelegate {
  func managerStateDidChange(_ manager: DNSProxyManager)
}

class DNSProxyManager: NSObject {

  private let manager = NEDNSProxyManager.shared()
  var delegate: DNSProxyManagerDelegate?
  private(set) var isEnabled: Bool = false {
    didSet {
      delegate?.managerStateDidChange(self)
    }
  }

  var completion: (() -> Void)?

  override init() {
    super.init()
    self.load()
  }

  func toggle() {
    isEnabled ? disable() : start()
  }
  
  private func start() {
    let request = OSSystemExtensionRequest
      .activationRequest(forExtensionWithIdentifier: extensionBundleID,
                         queue: DispatchQueue.main)

    request.delegate = self
    OSSystemExtensionManager.shared.submitRequest(request)
    log.info("Submitted extension activation request")
  }

  private func enable() {
    update {
      self.manager.localizedDescription = "DNS"
      let proto = NEDNSProxyProviderProtocol()
      proto.providerBundleIdentifier = extensionBundleID
      self.manager.providerProtocol = proto
      self.manager.isEnabled = true
    }
  }

  private func disable() {
    update {
      self.manager.isEnabled = false
    }
  }

  private func remove() {
    update {
      self.manager.removeFromPreferences { _ in
        self.isEnabled = self.manager.isEnabled
      }
    }
  }


  private func update(_ body: @escaping () -> Void) {
    self.manager.loadFromPreferences { (error) in
      if let error = error {
        log.error("Failed to load DNS manager: \(error)")
        return
      }

      body()
      self.manager.saveToPreferences { (error) in
        if let error = error {
          log.error("Failed to save DNS manager: \(error)")
          return
        }
        log.info("Saved DNS manager")
        self.isEnabled = self.manager.isEnabled
      }
    }
  }

  private func load() {
    manager.loadFromPreferences { error in
      guard error == nil else { return }
      self.isEnabled = self.manager.isEnabled
    }
  }

}

extension DNSProxyManager: OSSystemExtensionRequestDelegate {


  func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
    log.info("Extension activation request needs user approval")
  }

  func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
    log.error("Extension activation request failed: \(error)")
  }

  func request(_ request: OSSystemExtensionRequest, foundProperties properties: [OSSystemExtensionProperties]) {
    log.info("Extension activation request found properties: \(properties)")
  }

  func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
    guard result == .completed else {
      log.error("Unexpected result \(result.description) for system extension request")
      return
    }

    log.info("Extension activation request did finish with result: \(result.description)")
    enable()

  }

  func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
    log.info("Existing extension willt be replaced: \(existing.bundleIdentifier) -> \(ext.bundleIdentifier)")
    return .replace
  }

}


extension OSSystemExtensionRequest.Result {

  var description: String {
    switch self {
    case .completed: return "Completed"
    case .willCompleteAfterReboot: return "Will complete after reboot"
    }
  }
}
