import SwiftUI

@main
struct DNSProxyApp: App {
  
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


