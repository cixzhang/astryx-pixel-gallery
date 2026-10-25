import Astryx
import AstryxNative
import SwiftUI

struct ListItemScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Bullets on the first line: center, start, first line") {
        Astryx.List(listStyle: .disc) {
          ListItem("Center: a label long enough to wrap onto a second line", description: "Supporting words", align: .center)
          ListItem("Start: a label long enough to wrap onto a second line", description: "Supporting words", align: .start)
          ListItem("First line: a label long enough to wrap onto a second line", description: "Supporting words", align: .firstLine)
        }
      }
      CaptureRow(title: "Circle and numbered markers") {
        HStack(alignment: .top, spacing: 12) {
          Astryx.List(listStyle: .circle) {
            ListItem("Flour")
            ListItem("Sugar")
            ListItem("Eggs")
          }
          Astryx.List(listStyle: .decimal) {
            ListItem("Preheat")
            ListItem("Mix")
            ListItem("Bake")
          }
        }
      }
      CaptureRow(title: "Dividers: square selected row; disabled row") {
        Astryx.List(hasDividers: true) {
          ListItem("Wi-Fi", description: "Home") { Icon(.check) } onClick: {}
          ListItem("Bluetooth", description: "On", isSelected: true) { Icon(.check) } onClick: {}
          ListItem("AirDrop", description: "Off", isDisabled: true) { Icon(.check) } onClick: {}
        }
      }
      CaptureRow(title: "Padded and flush edges on a filled container") {
        VStack(spacing: 8) {
          Astryx.List(edge: .padded) { ListItem("Padded", isSelected: true) }
            .background(Color.gray.opacity(0.15))
          Astryx.List(edge: .flush) { ListItem("Flush", isSelected: true) }
            .background(Color.gray.opacity(0.15))
        }
      }
      CaptureRow(title: "Compact and spacious density") {
        HStack(alignment: .top, spacing: 12) {
          Astryx.List(density: .compact, hasDividers: true) { ListItem("Compact"); ListItem("Compact") }
          Astryx.List(density: .spacious, hasDividers: true) { ListItem("Spacious"); ListItem("Spacious") }
        }
      }
      CaptureRow(title: "Alone: the same as Item") {
        ListItem("Ada Lovelace", description: "Mathematician")
      }
    }
  }
}
