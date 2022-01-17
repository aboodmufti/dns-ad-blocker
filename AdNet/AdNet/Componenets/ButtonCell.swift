import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .brightness(configuration.isPressed ? -0.05 : 0)
      .animation(.easeInOut, value: configuration.isPressed)
  }
}

struct ButtonCell: View {

  var title: String
  var subtitle: String?
  var isEnabled: Bool = true
  var color: Color?
  var action: (() -> Void)?

  var body: some View {
    Button(action: { action?() }) {
      VStack(spacing: 2) {
        Text(title)
          .font(.system(size: 17))
          .fontWeight(titleWeight)
        if let subtitle = subtitle {
          Text(subtitle)
            .font(.system(size: 15))
        }
      }.foregroundColor(.white)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(color ?? (isEnabled ? Color.blue : Color.gray))
        .cornerRadius(5)
    }.buttonStyle(ScaleButtonStyle())
    .disabled(!isEnabled)
  }

  var titleWeight: Font.Weight { subtitle == nil ? .regular : .semibold }

}
