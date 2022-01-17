import SwiftUI


struct InfoCell: View {

  enum Status {
    case good, bad, neutral
  }

  var title: String
  var subtitle: String?
  var status: Status = .neutral

  var body: some View {
    HStack {
      Text(title)
        .foregroundColor(.white)
        .font(.system(size: 17))
        .padding([.leading,.trailing], 10)
      Spacer()
      if let subtitle = subtitle {
        Text(subtitle)
          .foregroundColor(.white)
          .font(.system(size: 15))
          .padding([.leading,.trailing], 10)
      }
    }
    .multilineTextAlignment(.leading)
    .frame(maxWidth: .infinity, minHeight: 50)
    .background(backgroundColor)
    .cornerRadius(5)
  }

  var backgroundColor: Color {
    switch status {
    case .bad: return Color.red
    case .good: return Color.green
    case .neutral: return Color.gray
    }
  }
}

