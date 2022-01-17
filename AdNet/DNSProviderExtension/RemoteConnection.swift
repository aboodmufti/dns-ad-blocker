import NetworkExtension

protocol RemoteConnectionDelegate {
  func connectionReceivedData(_ data: Data, from connection: RemoteConnection)
  func connectionFailed(error: Error?, from connection: RemoteConnection)
  func connectionSentData(connection: RemoteConnection)
}

class RemoteConnection {

  var remoteEndpoint: NWHostEndpoint
  var connection: NWConnection?
  var delegate: RemoteConnectionDelegate
  var packetQueue: [Data] = []

  var queue: DispatchQueue = DispatchQueue(label: "RemoteConnection-\(shortUUID())")

  var isReady: Bool = false {
    didSet {
      guard isReady else { return }
      receiveUDP()
      for packet in packetQueue {
        sendUDP(packet)
      }
      packetQueue = []
    }
  }

  init(remoteEndpoint: NWHostEndpoint, delegate: RemoteConnectionDelegate) {
    self.remoteEndpoint = remoteEndpoint
    self.delegate = delegate
    defer { openConnection() }
  }

  func openConnection() {
    guard let endpoint = remoteEndpoint.networkEndpoint else {
      log.error("Failed to create outbound endpoint")
      return
    }

    let connection = NWConnection(to: endpoint, using: .udp)

    connection.stateUpdateHandler = { newState in
      switch newState {
      case .ready:
        log.verbose("UDP socket state: ready")
        self.connection = connection
        self.isReady = true
      case .waiting(let error):
        log.verbose("UDP socket state: waiting - \(error)")
        self.isReady = false
        self.close()
        self.delegate.connectionFailed(error: error, from: self)
      case .failed(let error):
        log.verbose("UDP socket state: failed - \(error)")
        self.isReady = false
        self.close()
        self.delegate.connectionFailed(error: error, from: self)
      default:
        log.verbose("UDP socket state: \(newState)")
        self.isReady = false
      }
    }

    connection.start(queue: queue)
  }

  func sendUDP(_ data: Data) {
    guard isReady else {
      packetQueue.append(data)
      return
    }

    connection?.send(content: data, completion: .contentProcessed({ error in
      if let error = error {
        log.verbose("Failed to send UDP packet: \(error)")
        self.close()
        self.delegate.connectionFailed(error: error, from: self)
        return
      }
      self.delegate.connectionSentData(connection: self)
      log.verbose("Sent UDP packet successfuly")
    }))
  }

  func receiveUDP() {
    connection?.receive(minimumIncompleteLength: 1, maximumLength: 2048) { data, _, isComplete, error in
      if let error = error {
        log.verbose("Failed to receive UDP packet: \(error)")
        self.close()
        self.delegate.connectionFailed(error: error, from: self)
        return
      }

      if let data = data {
        log.verbose("Received UDP packets")
        self.delegate.connectionReceivedData(data, from: self)
        self.receiveUDP()
      }
    }
  }

  func close() {
    connection?.cancel()
  }

}
