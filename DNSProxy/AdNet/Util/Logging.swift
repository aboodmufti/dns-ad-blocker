

class AppLogger: Logger {

  let minLogLevel: LogLevel

  init(_ minLogLevel: LogLevel) {
    self.minLogLevel = minLogLevel
  }

  func log(level: LogLevel, _ message: @autoclosure () -> String, _ file: StaticString, _ function: StaticString, _ line: UInt) {
    guard level >= minLogLevel else { return }
    print("[\(level.symbol)] - \(message())")
  }
  
}



