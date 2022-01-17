import SwiftUI

struct BlockListView: View {

  @StateObject var viewModel = BlockListViewModel()

  var body: some View {
    VStack {
      ScrollView {
        ForEach(BlockList.allCases, id: \.rawValue) { list in
          SelectableCell(title: list.displayName,
                         subtitle: list.displayURL,
                         isSelected: viewModel.selectedLists[list.rawValue] ?? false) {
            viewModel.toggle(list: list)
          }
        }
      }
      if viewModel.isChanged {
        HStack {
          ButtonCell(title: "Cancel", color: .gray) {
            viewModel.cancel()
          }
          ButtonCell(title: "Save", color: .green) {
            viewModel.save()
          }
        }
      }

    }
  }
}


struct BlockListView_Previews: PreviewProvider {
  static var previews: some View {
    BlockListView()
  }
}

