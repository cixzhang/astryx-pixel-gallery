import Astryx
import AstryxNative
import SwiftUI

struct TextInputDetachedScreen: View {
  @State private var email = "you@example.com"
  @State private var name = ""
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Status detached") {
        TextInput(label: "Detached", value: "you@", status: TextInputStatus(type: .error, message: "Enter a full address"), statusVariant: .detached)
      }
      CaptureRow(title: "Status in a tip, with clear") {
        TextInput(label: "Tip", value: "you@", status: TextInputStatus(type: .error, message: "Enter a full address"), statusVariant: .tooltip, hasClear: true)
      }
      CaptureRow(title: "Loading") {
        TextInput(label: "Checking", value: "astryx", isLoading: true)
      }
    }
  }
}
