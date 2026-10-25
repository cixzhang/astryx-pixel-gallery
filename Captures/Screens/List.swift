import Astryx
import AstryxNative
import SwiftUI

struct ListScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Spaced and divided") {
        HStack(alignment: .top, spacing: 12) {
          Astryx.List { ListItem("One"); ListItem("Two"); ListItem("Three") }
          Astryx.List(hasDividers: true) { ListItem("One"); ListItem("Two"); ListItem("Three") }
        }
      }
      CaptureRow(title: "Numbered from 3; rows from ForEach") {
        HStack(alignment: .top, spacing: 12) {
          Astryx.List(listStyle: .decimal, start: 3) { ListItem("Mix"); ListItem("Bake"); ListItem("Cool") }
          Astryx.List(listStyle: .decimal) { ForEach(["Alpha", "Beta", "Gamma"], id: \.self) { ListItem($0) } }
        }
      }
      CaptureRow(title: "Circle markers; selected and disabled rows") {
        HStack(alignment: .top, spacing: 12) {
          Astryx.List(listStyle: .circle) { ListItem("Flour"); ListItem("Sugar"); ListItem("Eggs") }
          Astryx.List(hasDividers: true) {
            ListItem("Wi-Fi", isSelected: true) {} onClick: {}
            ListItem("AirDrop", isDisabled: true) {} onClick: {}
            ListItem("Bluetooth") {} onClick: {}
          }
        }
      }
      CaptureRow(title: "Nested lists count apart") {
        Astryx.List(listStyle: .decimal) {
          ListItem("Gather")
          Astryx.List(listStyle: .disc) { ListItem("Flour"); ListItem("Sugar") }
            .padding(.leading, 24)
          ListItem("Mix")
          ListItem("Bake")
        }
      }
      CaptureRow(title: "With a header") {
        Astryx.List(hasDividers: true) {
          ListItem("Notifications", description: "On") { Icon(.check) } onClick: {}
          ListItem("Sounds", description: "Chime") { Icon(.check) } onClick: {}
        } header: {
          Heading("Settings", level: 3)
        }
      }
      CaptureRow(title: "Flush, inside a padded container") {
        Astryx.List(hasDividers: true, edge: .flush) {
          ListItem("Storage", description: "64 GB")
          ListItem("Battery", description: "88%")
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
      }
    }
  }
}
