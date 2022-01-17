
var log: Logger = DefaultLogger(.verbose)

class DefaultLogger: Logger {

  let minLogLevel: LogLevel

  init(_ minLogLevel: LogLevel) {
    self.minLogLevel = minLogLevel
  }

  func log(level: LogLevel, _ message: @autoclosure () -> String, _ file: StaticString, _ function: StaticString, _ line: UInt) {
    guard level >= minLogLevel else { return }
    print("[\(level.symbol)] - \(message())")
  }

  func sourceFileName(_ path: StaticString) -> String {
    let components = path.description.components(separatedBy: "/")
    return components.last ?? ""
  }
}



@frozen
public enum LogLevel: Int {
  case verbose, debug, info, warning, error

  var symbol: String {
    switch self {
    case .verbose : return "v"
    case .debug   : return "d"
    case .info    : return "i"
    case .warning : return "w"
    case .error   : return "e"
    }
  }
}


extension LogLevel: Comparable {
  public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

protocol Logger {
  func log(level: LogLevel, _ message: @autoclosure () -> String, _ file: StaticString, _ function: StaticString, _ line: UInt)
}

extension Logger {
  func verbose(_ message: @autoclosure () -> String, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
    log(level: .verbose, message(), file, function, line)
  }

  func debug(_ message: @autoclosure () -> String, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
    log(level: .debug, message(), file, function, line)
  }

  func info(_ message: @autoclosure () -> String, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
    log(level: .info, message(), file, function, line)
  }

  func warning(_ message: @autoclosure () -> String, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
    log(level: .warning, message(), file, function, line)
  }

  func error(_ message: @autoclosure () -> String, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
    log(level: .error, message(), file, function, line)
  }
}

class NOOPLogger: Logger {

  func log(level: LogLevel, _ message: @autoclosure () -> String, _ file: StaticString, _ function: StaticString, _ line: UInt) {
    // NOOP
  }

}
