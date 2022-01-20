import Foundation

class BlockListViewModel: ObservableObject {

  var originalSelectedList: [String: Bool]?

  @Published var selectedLists: [String: Bool] = {
    if let stored = Store.shared.dictionary(.selectedBlockLists) {
      return stored
    }

    var defaultList = BlockList.allCases.reduce(into: [String: Bool]()) { $0[$1.rawValue] = false }
    defaultList[BlockList.oisd.rawValue] = true
    return defaultList
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
    Store.shared.set(selectedLists, .selectedBlockLists)
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
