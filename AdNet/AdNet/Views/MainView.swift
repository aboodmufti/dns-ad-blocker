import SwiftUI

struct MainView: View {

  @EnvironmentObject var mainViewModel: MainViewModel

  var body: some View {
    TabView {
      GeneralView()
        .tabItem {
            Text("General")
        }
      BlockListView()
          .tabItem {
              Text("Lists")
          }
    }
    .padding()
    .frame(width: 500, height: 300, alignment: .topLeading)
  }

}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}

