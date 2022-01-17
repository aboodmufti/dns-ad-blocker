import Foundation

fileprivate class TrieNode {
  var children: [String: TrieNode] = [:]
  var isFull: Bool = false
}

class Trie {

  static let queue = DispatchQueue(label: "Trie")

  private var root = TrieNode()

  private func splitDomain(_ domain: String) -> [String] {
    return domain.split(separator: ".").map { String($0) }
  }

  func add(domain: String) {
    var parts = splitDomain(domain)
    guard !parts.isEmpty else { return }

    var node = root

    while let last = parts.popLast() {
      let child = node.children[last] ?? TrieNode()

      if node.children[last] == nil {
        node.children[last] = child
      }

      node = child
    }

    node.isFull = true
  }

  func contains(domain: String) -> Bool {
    var parts = splitDomain(domain)
    var node = root

    while let last = parts.popLast() {
      guard let child = node.children[last] else {
        return false
      }

      if node.isFull {
        return true
      }

      node = child
    }

    return node.isFull
  }
}
