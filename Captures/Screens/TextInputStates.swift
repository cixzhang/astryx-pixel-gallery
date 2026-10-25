import Astryx
import AstryxNative
import SwiftUI

struct TextInputStatesScreen: View {
  @State private var email = "you@example.com"
  @State private var name = ""
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Read-only; read-only password; empty read-only with placeholder") {
        VStack(spacing: 8) {
          TextInput(label: "Read-only", value: "ID 12345", isReadOnly: true)
          TextInput(label: "Read-only password", value: "hunter2", type: .password, isReadOnly: true)
          TextInput(label: "Notes", value: "", isReadOnly: true, placeholder: "None")
        }
      }
      CaptureRow(title: "Disabled with a reason; disabled; hidden label (description hidden); both notes") {
        VStack(spacing: 8) {
          TextInput(label: "Disabled", value: "Managed", isDisabled: true, disabledMessage: "Managed by your admin")
          TextInput(label: "Disabled", value: "Plain", isDisabled: true)
          TextInput(label: "Search", value: "", isLabelHidden: true, description: "Hidden with the label", placeholder: "Search (label hidden)")
          TextInput(label: "Both notes", value: "", isOptional: true, isRequired: true)
        }
      }
    }
  }
}
