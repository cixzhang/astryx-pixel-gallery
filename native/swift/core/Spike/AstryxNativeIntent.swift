// SPIKE — not Astryx API. Native intent as swift-ios-1 would receive it from
// the generator (PR 8031 OQ3), including PROPOSED members P1–P4.

import SwiftUI

public struct AstryxNativeIntent: Equatable, Sendable {
  /// Durable `material` plus iOS's own term (main's vocabulary).
  public enum Material: String, Sendable {
    case opaque
    case translucent
    case liquidGlass
  }

  /// P1 (proposed): how surface corners are drawn.
  public enum Corners: String, Sendable {
    case smooth
    case stepped
  }

  /// P2 (proposed): how raster images scale up.
  public enum ImageScaling: String, Sendable {
    case smooth
    case pixelated
  }

  /// A platform icon: an SF Symbol (main) or an asset-catalog image (P4).
  public enum IconRef: Equatable, Sendable {
    case system(String)
    case asset(String)
  }

  public var material: Material?
  public var corners: Corners
  public var imageScaling: ImageScaling
  /// P3 (proposed): the typeface's design grid in units per em; 0 is off.
  public var textGrid: Double
  /// iOS theme-target overrides; values are token names.
  public var components: [String: [String: String]]
  public var icons: [String: IconRef]

  public init(
    material: Material?,
    corners: Corners,
    imageScaling: ImageScaling,
    textGrid: Double,
    components: [String: [String: String]],
    icons: [String: IconRef]
  ) {
    self.material = material
    self.corners = corners
    self.imageScaling = imageScaling
    self.textGrid = textGrid
    self.components = components
    self.icons = icons
  }

  public static let none = AstryxNativeIntent(
    material: nil,
    corners: .smooth,
    imageScaling: .smooth,
    textGrid: 0,
    components: [:],
    icons: [:]
  )
}
