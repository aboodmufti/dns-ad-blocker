import SwiftUI

struct GeneralView: View {

  @EnvironmentObject var viewModel: MainViewModel

  var timer: Timer?

  var body: some View {

    VStack(spacing: 10) {
      InfoCell(title: "Requests Blocked:", subtitle: "\(viewModel.requestsBlocked)", status: .neutral)
      Spacer()
      ButtonCell(title: (viewModel.isProxyEnabled ?  "Disable" : "Enable" ),
                 color: viewModel.isProxyEnabled ? .red : .blue) {
        self.viewModel.toggleProxy()
      }
    }
    .frame(alignment: .topLeading)
    .padding()
  }


}
