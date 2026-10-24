import Astryx
import AstryxNative
import SwiftUI

private let photo = "https://avatars.githubusercontent.com/u/69631?s=256&v=4"
private let broken = "https://invalid.invalid/missing.png"

struct ThumbnailScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Image, no image, failed image") {
        Flow(spacing: 12) {
          Thumbnail(src: photo, alt: "Logo", label: "logo.png")
          Thumbnail(label: "empty.png")
          Thumbnail(src: broken, label: "missing.png")
        }
      }
      CaptureRow(title: "Loading: skeleton (no image), upload (with image)") {
        Flow(spacing: 12) {
          Thumbnail(label: "pending.png", isLoading: true)
          Thumbnail(src: photo, label: "uploading.png", isLoading: true)
        }
      }
      CaptureRow(title: "Remove (hover shows on touch), remove always, tappable") {
        Flow(spacing: 12) {
          Thumbnail(src: photo, label: "a.png", onRemove: {})
          Thumbnail(src: photo, label: "b.png", showRemoveOn: .always, onRemove: {})
          Thumbnail(src: photo, label: "c.png", onClick: {}, onRemove: {})
        }
      }
      CaptureRow(title: "Disabled (no remove, no tap)") {
        Flow(spacing: 12) {
          Thumbnail(src: photo, label: "d.png", isDisabled: true, onClick: {}, onRemove: {})
          Thumbnail(label: "e.png", isDisabled: true)
        }
      }
      CaptureRow(title: "Themes: neutral and butter") {
        Flow(spacing: 12) {
          Thumbnail(label: "n.png", onRemove: {}).astryxTheme(.neutral)
          Thumbnail(label: "b.png", onRemove: {}).astryxTheme(.butter)
        }
      }
    }
  }
}
