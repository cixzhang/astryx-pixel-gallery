import Astryx
import AstryxNative
import SwiftUI

struct TextInputScreen: View {
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
      CaptureRow(title: "Status attached: error, warning, success") {
        VStack(spacing: 8) {
          TextInput(label: "Email", value: "you@", status: TextInputStatus(type: .error, message: "Enter a full address"))
          TextInput(label: "Domain", value: "example.org", status: TextInputStatus(type: .warning, message: "Not your company domain"))
          TextInput(label: "Handle", value: "astryx", status: TextInputStatus(type: .success, message: "Available"))
        }
      }
      CaptureRow(title: "Status detached; status in a tip") {
        VStack(spacing: 8) {
          TextInput(label: "Detached", value: "you@", status: TextInputStatus(type: .error, message: "Enter a full address"), statusVariant: .detached)
          TextInput(label: "Tip", value: "you@", status: TextInputStatus(type: .error, message: "Enter a full address"), statusVariant: .tooltip)
        }
      }
      CaptureRow(title: "Loading; read-only; disabled with a reason; hidden label") {
        VStack(spacing: 8) {
          TextInput(label: "Checking", value: "astryx", isLoading: true)
          TextInput(label: "Read-only", value: "ID 12345", isReadOnly: true)
          TextInput(label: "Read-only password", value: "hunter2", type: .password, isReadOnly: true)
          TextInput(label: "Disabled", value: "Managed", isDisabled: true, disabledMessage: "Managed by your admin")
          TextInput(label: "Search", value: "", isLabelHidden: true, description: "Hidden with the label", placeholder: "Search (label hidden, description hidden)")
          TextInput(label: "Both notes", value: "", isOptional: true, isRequired: true)
        }
      }
    }
  }
}
