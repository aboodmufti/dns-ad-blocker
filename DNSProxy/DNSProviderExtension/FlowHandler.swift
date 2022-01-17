import NetworkExtension
import DNS

protocol FlowHandlerDelegate {
  func flowClosed(_ handler: FlowHandler)
  func flowBlockedDomain()
}

class FlowHandler {

  let id: String
  let flow: NEAppProxyUDPFlow
  let remoteEndpoint: NWHostEndpoint
  let delegate: FlowHandlerDelegate
  var connections: [String: RemoteConnection] = [:]

  init(flow: NEAppProxyUDPFlow, remoteEndpoint: NWEndpoint, id: String, delegate: FlowHandlerDelegate) {
    self.flow = flow
    self.remoteEndpoint = remoteEndpoint as! NWHostEndpoint
    self.id = id
    self.delegate = delegate
    defer { start() }
  }

  deinit {
    closeAll(nil)
  }
  
  func start() {
    flow.open(withLocalEndpoint: flow.localEndpoint as? NWHostEndpoint) { error in
      if let error = error {
        log.verbose("Failed to open flow: \(error)")
        self.delegate.flowClosed(self)
        return
      }

      log.verbose("Opened flow successfuly")
      self.readFromFlow()
    }
  }

  func readFromFlow() {
    self.flow.readDatagrams { packets, endpoint, error in
      if let error = error {
        log.verbose("Failed to read from flow: \(error)")
        self.closeAll(error)
        return
      }

      guard let packets = packets, let endpoints = endpoint, !packets.isEmpty, !endpoints.isEmpty else {
        log.verbose("Flow has no more packets")
        self.closeAll(nil)
        return
      }

      self.processFlowPackets(packets, endpoints)
      self.readFromFlow()
    }
  }

  func writeToFlow(_ data: Data, sendtBy endpoint: NWEndpoint) {
    self.flow.writeDatagrams([data], sentBy: [endpoint]) { error in
      if let error = error {
        log.verbose("Failed to write to flow: \(error)")
        self.closeAll(error)
        return
      }

      log.verbose("Wrote to flow successfuly")
    }
  }

  func processFlowPackets(_ packets: [Data], _ endpoints: [NWEndpoint]) {
    guard packets.count == endpoints.count else {
      log.error("Missmatch in packets and endpoints counts")
      self.closeAll(nil)
      return
    }

    for i in 0..<packets.count {
      processPacket(packets[i], endpoints[i])
    }
  }

  func processPacket(_ packet: Data, _ endpoint: NWEndpoint) {
    guard let message = try? Message(deserialize: packet) else {
      self.closeAll(nil)
      return
    }

    if message.type == .query {
      for question in message.questions {
        log.verbose("Question Name: \(question.name)")
        if isDomainBlocked(question.name) {
          log.verbose("Domain Blocked: \(question.name)")
          let response = self.createBlockMessage(from: message)
          guard let responseData = try? response.serialize() else { continue }
          self.delegate.flowBlockedDomain()
          self.writeToFlow(responseData, sendtBy: endpoint)
        } else {
          self.sendOutboundPacket(packet, endpoint)
        }
      }
    } else {
      self.sendOutboundPacket(packet, endpoint)
    }
  }

  func isDomainBlocked(_ domain: String) -> Bool {
    let cleanDomain = String(domain.prefix(domain.count-1))
    let isBlocked = blockedDomains.contains(domain: cleanDomain)
    return isBlocked
  }

  func sendOutboundPacket(_ packet: Data, _ endpoint: NWEndpoint) {
    guard let endpoint = endpoint as? NWHostEndpoint else {
      self.closeAll(nil)
      return
    }

    let connection = connections[endpoint.string] ?? RemoteConnection(remoteEndpoint: endpoint, delegate: self)

    if connections[endpoint.string] == nil {
      connections[endpoint.string] = connection
    }

    log.verbose("Sending packet")
    connection.sendUDP(packet)
  }

  func createBlockMessage(from msg: Message) -> Message {
    let ip = IPv4("0.0.0.0")!
    let record = HostRecord<IPv4>(name: "Blocked", ttl: .max, ip: ip)
    return Message(id: msg.id,
                   type: .response,
                   operationCode: msg.operationCode,
                   authoritativeAnswer: true,
                   truncation: false,
                   recursionDesired: msg.recursionDesired,
                   recursionAvailable: true,
                   returnCode: .queryRefused, //.nonExistentDomain
                   questions: [], answers: [record], authorities: [] , additional: [])
  }

  func closeAll(_ error: Error? = nil) {
    flow.closeReadWithError(error)
    flow.closeWriteWithError(error)
    connections.values.forEach { $0.close() }
    delegate.flowClosed(self)
  }
}


extension FlowHandler: RemoteConnectionDelegate {
  func connectionFailed(error: Error?, from connection: RemoteConnection) {
    closeAll(error)
  }

  func connectionReceivedData(_ data: Data, from connection: RemoteConnection) {
    writeToFlow(data, sendtBy: connection.remoteEndpoint)
  }

  func connectionSentData(connection: RemoteConnection) {
    log.verbose("Sent UDP data")
  }

}
