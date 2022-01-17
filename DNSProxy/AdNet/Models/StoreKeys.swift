import Foundation

enum StoreKey: String {
  case numberOfRequestsBlocked
  case selectedBlockLists
}


extension UserDefaults {
  func incrementInteger(_ key:String) {
    set(integer(forKey: key)+1, forKey: key)
  }
}
