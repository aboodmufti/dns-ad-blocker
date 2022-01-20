import Foundation


class Store {

  static let shared = Store()
  private let defaults = UserDefaults.standard

  func set(_ value: Any?, _ key: StoreKey) {
    defaults.set(value, forKey: key.rawValue)
  }

  func dictionary(_ key: StoreKey) -> [String : Bool]? {
    return defaults.dictionary(forKey: key.rawValue) as? [String: Bool]
  }

  func integer(_ key: StoreKey) -> Int {
    return defaults.integer(forKey: key.rawValue)
  }

  func incrementInteger(_ key: StoreKey) {
    defaults.set(integer(key)+1, forKey: key.rawValue)
  }

}
