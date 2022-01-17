import Foundation
import NetworkExtension

autoreleasepool {
  NEProvider.startSystemExtensionMode()
  log = ExtensionLogger(.debug)
  IPCConnection.shared.startListener()
}

dispatchMain()
