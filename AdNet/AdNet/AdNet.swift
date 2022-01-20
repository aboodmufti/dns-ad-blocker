import SwiftUI

@main
struct AdNetApp: App {
  
  @StateObject var mainViewModel = MainViewModel()

  init() {
    log = AppLogger(.verbose)

    if Store.shared.dictionary(.selectedBlockLists) == nil {
      Store.shared.set(BlockList.defaultLists, .selectedBlockLists)
    }
    
  }

  var body: some Scene {
    WindowGroup {
      MainView().environmentObject(mainViewModel)
    }
  }
}


