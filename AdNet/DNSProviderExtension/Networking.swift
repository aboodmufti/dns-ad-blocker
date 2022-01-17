import Foundation

class Networking {

  class func downloadFile(from url: String) {
    guard let url = URL(string: url) else {
      log.error("Failed to create URL")
      return
    }

    let session = URLSession(configuration: .default)

    let task = session.downloadTask(with: url) { location, response, error in
      if let error = error {
        log.error("Failed to download file: \(error)")
        return
      }

      guard let location = location else { return }

      let content = try? String(contentsOf: location)
      processURLContent(content)
    }

    task.resume()
  }

  class func processURLContent(_ content: String?) {
    guard var content = content else { return }
    // force NSString -> String bridge for faster processing
    // https://forums.swift.org/t/difficulties-with-efficient-large-file-parsing/23660/8
    content += ""

    Trie.queue.async {
      let lines = content.split(separator: "\n")

      for line in lines {
        if line.hasPrefix("||") {
          let size = line.count
          let domain = String(line.suffix(size-2).prefix(size-3))
          blockedDomains.add(domain: domain)
        }
      }
    }
  }

}
