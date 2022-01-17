import SwiftUI

struct SelectableCell: View {

  var title: String
  var subtitle: String?
  var isSelected = false
  var action: (() -> Void) = {}

  var vertical: some View {
    VStack(alignment: .leading) {
      Text(title)
        .foregroundColor(.black)
        .font(.system(size: 17, weight: .medium))
        .fixedSize(horizontal: true, vertical: false)
      if let subtitle = subtitle {
        Text(subtitle)
          .foregroundColor(.black)
          .font(.system(size: 13, weight: .ultraLight))
          .fixedSize(horizontal: true, vertical: false)
      }
    }
  }

  var body: some View {
    HStack {
      Button(action: action) {
        Group {
          vertical
        }.frame(maxWidth: .infinity,
                minHeight: 50,
                maxHeight: .infinity,
                alignment: .leading)
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background(isSelected ? Color.blue : Color.gray)
          .cornerRadius(10)
      }.buttonStyle(ScaleButtonStyle())
    }.padding(.horizontal, 10)
  }
}
