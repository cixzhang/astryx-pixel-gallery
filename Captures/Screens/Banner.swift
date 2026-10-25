import Astryx
import SwiftUI

struct BannerScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Statuses: info, success, warning, error") {
        VStack(spacing: 8) {
          Banner(status: .info, title: "Update available", description: "Restart to finish installing.")
          Banner(status: .success, title: "Saved")
          Banner(status: .warning, title: "Storage almost full", description: "Free up space to keep syncing.")
          Banner(status: .error, title: "Couldn't send", description: "Check your connection and try again.")
        }
      }
      CaptureRow(title: "Two themes: neutral, butter") {
        VStack(spacing: 8) {
          Banner(status: .info, title: "Neutral").astryxTheme(.neutral)
          Banner(status: .info, title: "Butter").astryxTheme(.butter)
        }
      }
    }
  }
}
