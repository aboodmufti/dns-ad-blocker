import Foundation
import NetworkExtension

autoreleasepool {
  NEProvider.startSystemExtensionMode()
  log = NOOPLogger()
  IPCConnection.shared.startListener()
}

dispatchMain()
