import Foundation
import NetworkExtension
import SystemExtensions
import SwiftUI


class MainViewModel: ObservableObject {

  private let manager: DNSProxyManager
  private var timer: Timer?

  @Published var requestsBlocked: Int = 0
  @Published var isProxyEnabled: Bool = false {
    didSet {
      if isProxyEnabled {
        requestsBlocked = UserDefaults.standard.integer(forKey: StoreKey.numberOfRequestsBlocked.rawValue)
        registerWithProvider()
      }
    }
  }

  init() {
    manager = DNSProxyManager()
    manager.delegate = self
  }

  func toggleProxy() {
    manager.toggle()
  }

  lazy var extensionBundle: Bundle? = {
    let extensionsDirectoryURL = URL(fileURLWithPath: "Contents/Library/SystemExtensions", relativeTo: Bundle.main.bundleURL)
    let extensionURLs: [URL]
    do {
      extensionURLs = try FileManager.default.contentsOfDirectory(at: extensionsDirectoryURL,
                                                                  includingPropertiesForKeys: nil,
                                                                  options: .skipsHiddenFiles)
    } catch let error {
      log.error("Failed to get the contents of \(extensionsDirectoryURL.absoluteString): \(error.localizedDescription)")
      return nil
    }

    guard let extensionURL = extensionURLs.first else {
      log.error("Failed to find any system extensions")
      return nil
    }

    guard let extensionBundle = Bundle(url: extensionURL) else {
      log.error("Failed to create a bundle with URL \(extensionURL.absoluteString)")
      return nil
    }

    return extensionBundle
  }()

  func registerWithProvider() {
    guard let extensionBundle = extensionBundle else {
      log.error("Failed to create extension bundle")
      return
    }

    IPCConnection.shared.register(withExtension: extensionBundle, delegate: self) { _ in }
  }
}

extension MainViewModel: DNSProxyManagerDelegate {
  func managerStateDidChange(_ manager: DNSProxyManager) {
    isProxyEnabled = manager.isEnabled
  }
}



extension MainViewModel: AppCommunication {
  func dnsProxyBlockedRequest() {
    log.info("dnsProxyBlockedRequest")
    UserDefaults.standard.incrementInteger(StoreKey.numberOfRequestsBlocked.rawValue)
    DispatchQueue.main.async {
      self.requestsBlocked += 1
    }
  }

  func getBlockLists(_ completion: @escaping ([String]) -> Void) {
    log.info("getBlockLists")
    let lists = UserDefaults.standard.dictionary(forKey: StoreKey.selectedBlockLists.rawValue) as? [String: Bool] ?? [:]

    let urls: [String] = lists.compactMap { k,v in
      guard v else { return nil }
      return BlockList(rawValue: k)?.downloadURL
    }

    completion(urls)
  }
}


