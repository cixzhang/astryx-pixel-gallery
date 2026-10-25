import Astryx
import AstryxNative
import SwiftUI

struct TextInputAttachedScreen: View {
  @State private var email = "you@example.com"
  @State private var name = ""
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Status attached: error, warning, success") {
        VStack(spacing: 8) {
          TextInput(label: "Email", value: "you@", status: TextInputStatus(type: .error, message: "Enter a full address"))
          TextInput(label: "Domain", value: "example.org", status: TextInputStatus(type: .warning, message: "Not your company domain"))
          TextInput(label: "Handle", value: "astryx", status: TextInputStatus(type: .success, message: "Available"))
        }
      }
    }
  }
}
