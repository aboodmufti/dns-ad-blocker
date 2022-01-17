import Foundation

class BlockListViewModel: ObservableObject {

  var originalSelectedList: [String: Bool]?

  @Published var selectedLists: [String: Bool] = {
    let stored = UserDefaults.standard.dictionary(forKey: StoreKey.selectedBlockLists.rawValue) as? [String: Bool]
    return stored ?? BlockList.allCases.reduce(into: [String: Bool]()) { $0[$1.rawValue] = false }
  }()

  private var isChanged_: Bool {
    guard let og = originalSelectedList else { return false }
    return selectedLists != og
  }

  @Published var isChanged: Bool = false

  func toggle(list: BlockList) {
    if originalSelectedList == nil {
      originalSelectedList = selectedLists
    }

    selectedLists[list.rawValue] = !selectedLists[list.rawValue, default: false]
    isChanged = isChanged_
  }

  func save() {
    UserDefaults.standard.set(selectedLists, forKey: StoreKey.selectedBlockLists.rawValue)
    originalSelectedList = nil
    isChanged = isChanged_

    let urls: [String] = selectedLists.compactMap { k,v in
      guard v else { return nil }
      return BlockList(rawValue: k)?.downloadURL
    }

    IPCConnection.shared.blockListsUpdated(urls: urls)
  }

  func cancel() {
    selectedLists = originalSelectedList ?? [:]
    originalSelectedList = nil
    isChanged = isChanged_
  }

}
