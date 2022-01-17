import Foundation

class ExtensionLogger: Logger {

  let minLogLevel: LogLevel

  init(_ minLogLevel: LogLevel) {
    self.minLogLevel = minLogLevel
  }

  func log(level: LogLevel, _ message: @autoclosure () -> String, _ file: StaticString, _ function: StaticString, _ line: UInt) {
    guard level >= minLogLevel else { return }
    NSLog("[DNSProxy] [\(level.symbol)] - \(message())")
  }

  func sourceFileName(_ path: StaticString) -> String {
    let components = path.description.components(separatedBy: "/")
    return components.last ?? ""
  }
}
