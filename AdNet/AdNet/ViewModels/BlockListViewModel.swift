import Foundation

class BlockListViewModel: ObservableObject {

  var originalSelectedList: [String: Bool]?

  @Published var selectedLists: [String: Bool] = [:]

  private var isChanged_: Bool {
    guard let og = originalSelectedList else { return false }
    return selectedLists != og
  }

  @Published var isChanged: Bool = false

  init() {
    if Store.shared.dictionary(.selectedBlockLists) == nil {
      Store.shared.set(BlockList.defaultLists, .selectedBlockLists)
    }

    selectedLists = Store.shared.dictionary(.selectedBlockLists) ?? BlockList.defaultLists

  }

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
