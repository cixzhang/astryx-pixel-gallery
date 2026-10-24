// Shows one capture screen, chosen by launch argument: `-screen Icon`.
import Astryx
import SwiftUI

@main
struct CapturesApp: App {
  var body: some Scene {
    WindowGroup {
      let name = UserDefaults.standard.string(forKey: "screen") ?? ""
      ScrollView {
        captureScreen(named: name)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(16)
      }
      .background(Color(uiColor: .systemBackground))
    }
  }
}

/// A titled row of states inside a capture screen.
struct CaptureRow<Content: View>: View {
  let title: String
  @ViewBuilder let content: Content
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      SwiftUI.Text(title).font(.caption).foregroundStyle(.secondary)
      content
    }
    .padding(.vertical, 6)
  }
}

/// Lays children out left to right and wraps to the next line, so a row of
/// states stays on screen at the largest text size.
struct Flow: Layout {
  var spacing: CGFloat = 12

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
    let width = rows.map { $0.width }.max() ?? 0
    let height = rows.reduce(0) { $0 + $1.height } + spacing * CGFloat(max(0, rows.count - 1))
    return CGSize(width: width, height: height)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    var y = bounds.minY
    for row in arrange(width: bounds.width, subviews: subviews) {
      var x = bounds.minX
      for index in row.indices {
        let size = subviews[index].sizeThatFits(.unspecified)
        subviews[index].place(at: CGPoint(x: x, y: y + (row.height - size.height) / 2), proposal: .unspecified)
        x += size.width + spacing
      }
      y += row.height + spacing
    }
  }

  private struct Row { var indices: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

  private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
    var rows: [Row] = [Row()]
    for index in subviews.indices {
      let size = subviews[index].sizeThatFits(.unspecified)
      let extra = rows[rows.count - 1].indices.isEmpty ? size.width : rows[rows.count - 1].width + spacing + size.width
      if extra > width && !rows[rows.count - 1].indices.isEmpty {
        rows.append(Row())
      }
      var row = rows[rows.count - 1]
      row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
      row.height = max(row.height, size.height)
      row.indices.append(index)
      rows[rows.count - 1] = row
    }
    return rows
  }
}
