import NetworkExtension


var blockedDomains = Trie()

class DNSProxyProvider: NEDNSProxyProvider {

  var handlers: [String: FlowHandler] = [:]
  var isReady = false
  let queue = DispatchQueue(label: "DNSProxyProvider")

  override func startProxy(options:[String: Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
    log.info("Starting DNS Proxy")
    IPCConnection.shared.appProxy?.getBlockLists({ urls in
      IPCConnection.shared.updatedBlockLists(urls: urls)
    })
    completionHandler(nil)
  }

  override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
    log.info("Stopping DNS Proxy")
    completionHandler()
  }

  override func handleNewUDPFlow(_ flow: NEAppProxyUDPFlow, initialRemoteEndpoint remoteEndpoint: NWEndpoint) -> Bool {

    let id = shortUUID()
    handlers[id] = FlowHandler(flow: flow, remoteEndpoint: remoteEndpoint, id: id, delegate: self)

    return true
  }

  override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
    return false
  }

}

extension DNSProxyProvider: FlowHandlerDelegate {
  func flowClosed(_ handler: FlowHandler) {
    handlers.removeValue(forKey: handler.id)
  }

  func flowBlockedDomain() {
    IPCConnection.shared.appProxy?.dnsProxyBlockedRequest()
  }
}


func shortUUID() -> String {
  let chars = [Character]("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")

  var code = ""
  for _ in 0..<6 {
    let random = Int(arc4random_uniform(62))
    code.append(chars[random])
  }
  return code
}
