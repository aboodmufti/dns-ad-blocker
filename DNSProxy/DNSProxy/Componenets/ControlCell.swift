import SwiftUI

struct ControlCell<Content: View>: View{

  var title: String
  var controlView: Content

  init(title: String, @ViewBuilder _ controlView: @escaping () -> Content) {
    self.title = title
    self.controlView = controlView()
  }

  var body: some View {
    HStack {
      Text(title)
        .foregroundColor(.black)
        .font(.system(size: 17))
        .fontWeight(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
      Spacer()
      controlView
    }
    .frame(maxWidth: .infinity,
           minHeight: 50,
           alignment: .leading)
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(Color.gray)
    .cornerRadius(10)
    .padding(.horizontal, 10)
  }
}
