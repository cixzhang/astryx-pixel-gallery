import Astryx
import AstryxNative
import SwiftUI

struct TextInputBasicsScreen: View {
  @State private var email = "you@example.com"
  @State private var name = ""
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Sizes sm md lg; placeholder") {
        VStack(spacing: 8) {
          TextInput(label: "Small", value: name, onChange: { name = $0 }, size: .sm, placeholder: "Placeholder")
          TextInput(label: "Medium", value: name, onChange: { name = $0 }, placeholder: "Placeholder")
          TextInput(label: "Large", value: name, onChange: { name = $0 }, size: .lg, placeholder: "Placeholder")
        }
      }
      CaptureRow(title: "Required, optional, description, label tip, clear") {
        VStack(spacing: 8) {
          TextInput(label: "Email", value: email, type: .email, onChange: { email = $0 }, description: "We'll send a link here", isRequired: true, labelTooltip: "Your work email", hasClear: true)
          TextInput(label: "Nickname", value: "", isOptional: true)
        }
      }
    }
  }
}
