import SwiftUI

@main
struct AdNetApp: App {
  
  @StateObject var mainViewModel = MainViewModel()

  init() {
    log = AppLogger(.verbose)
  }

  var body: some Scene {
    WindowGroup {
      MainView().environmentObject(mainViewModel)
    }
  }
}


