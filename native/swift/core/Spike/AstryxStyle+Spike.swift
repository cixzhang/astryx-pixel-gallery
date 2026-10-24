// SPIKE — not Astryx API. The theme hooks swift-ios-1's components would need
// for the pixel theme. Each is marked with the gap it closes (H1–H6 in the
// spike report). With `spikeHooks` off, every hook returns today's behavior.

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension AstryxStyle {
  // MARK: H1 — font family from `font-family-*` (PR 8031 G7)

  func themedFont(size: CGFloat, weight: Font.Weight, family token: String) -> Font {
    guard spikeHooks, let name = availableFamily(token) else {
      return .system(size: size, weight: weight)
    }
    if let design = AstryxStyle.genericDesign(name) {
      return .system(size: size, weight: weight, design: design)
    }
    // `fixedSize`: the size already carries Dynamic Type growth.
    return .custom(name, fixedSize: size).weight(weight)
  }

  /// The first family in the stack the app has, or a generic name that ends
  /// the walk. Nil means the system font.
  func availableFamily(_ token: String) -> String? {
    for family in tokens.fonts[token] ?? [] {
      if AstryxStyle.genericDesign(family) != nil { return family }
      if AstryxStyle.installedFamilies.contains(family) { return family }
    }
    return nil
  }

  static func genericDesign(_ family: String) -> Font.Design? {
    switch family {
    case "-apple-system", "system-ui", "BlinkMacSystemFont", "sans-serif": .default
    case "ui-monospace", "SF Mono", "monospace": .monospaced
    case "ui-serif", "serif": .serif
    case "ui-rounded": .rounded
    default: nil
    }
  }

  static var installedFamilies: Set<String> {
    #if canImport(UIKit)
    Set(UIFont.familyNames)
    #elseif canImport(AppKit)
    Set(NSFontManager.shared.availableFontFamilies)
    #else
    []
    #endif
  }

  // MARK: H2 — line height from `text-*-leading`

  /// Extra space between lines so a wrapped line advances by
  /// size × leading, as the web's line-height does.
  public func lineSpacing(type token: String, family: String = "font-family-body") -> CGFloat {
    guard spikeHooks, let leading = tokens.sizes["\(token)-leading"] else { return 0 }
    let size = fontSize("\(token)-size", 14)
    let natural: CGFloat
    #if canImport(UIKit)
    natural = (availableFamily(family).flatMap { UIFont(name: $0, size: size) } ?? .systemFont(ofSize: size)).lineHeight
    #elseif canImport(AppKit)
    let font = availableFamily(family).flatMap { NSFont(name: $0, size: size) } ?? .systemFont(ofSize: size)
    natural = font.ascender - font.descender + font.leading
    #else
    natural = size * 1.2
    #endif
    return max(0, size * leading - natural)
  }

  // MARK: H3 — text grid (proposed `textGrid`)

  func snapToTextGrid(_ size: CGFloat) -> CGFloat {
    guard spikeHooks, native.textGrid > 0, displayScale > 0 else { return size }
    // One design unit = size / grid. Keep it a whole number of device pixels.
    let unit = CGFloat(native.textGrid) / displayScale
    return max(unit, (size / unit).rounded() * unit)
  }

  // MARK: H4 — theme-target overrides (platforms.ios[].components)

  /// A token name a platform entry set for a target, when hooks are on.
  public func override(_ target: String, _ member: String) -> String? {
    spikeHooks ? native.components[target]?[member] : nil
  }

  /// A size token for `member`, the entry's token when it set one.
  public func overrideSize(_ target: String, _ member: String, token: String, _ fallback: CGFloat) -> CGFloat {
    size(override(target, member) ?? token, fallback)
  }

  public func overrideColor(_ target: String, _ member: String, token: String) -> Color {
    color(override(target, member) ?? token)
  }

  // MARK: H5 — surface shape and border (proposed `corners`)

  var isStepped: Bool { spikeHooks && native.corners == .stepped }

  /// The surface shape for a target: today's continuous rounded rectangle,
  /// or a staircase with `border-width` steps when corners are stepped.
  public func surfaceShape(_ target: String, radius token: String, _ fallback: CGFloat) -> AnyShape {
    let radius = overrideSize(target, "cornerRadius", token: token, fallback)
    guard isStepped else {
      return AnyShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
    let step = size("border-width", 1)
    return AnyShape(SteppedRectangle(step: step, steps: Int((radius / step).rounded())))
  }

  /// The surface border for a target, or nothing when neither the component
  /// nor the theme draws one.
  @ViewBuilder
  public func surfaceBorder(
    _ target: String,
    radius token: String,
    _ fallback: CGFloat,
    color defaultColor: String?,
    width defaultWidth: String = "border-width"
  ) -> some View {
    let colorToken = override(target, "borderColor") ?? defaultColor
    let width = size(override(target, "borderWidth") ?? defaultWidth, 1)
    let radius = overrideSize(target, "cornerRadius", token: token, fallback)
    if let colorToken {
      if isStepped {
        let step = size("border-width", 1)
        SteppedFrame(step: step, steps: Int((radius / step).rounded()), width: width)
          .fill(color(colorToken), style: FillStyle(eoFill: true))
      } else {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
          .strokeBorder(color(colorToken), lineWidth: width)
      }
    }
  }
}

// MARK: H6 — icons by shared name (platforms.ios[].icons, proposed asset form)

/// An Astryx icon by its shared name. The theme's platform icon wins; the
/// component's SF Symbol is the default (AST-082 FR17).
public struct AstryxIcon: View {
  let name: String
  let defaultSymbol: String
  let size: CGFloat
  @Environment(\.astryx) private var astryx

  public init(_ name: String, default defaultSymbol: String, size: CGFloat) {
    self.name = name
    self.defaultSymbol = defaultSymbol
    self.size = size
  }

  public var body: some View {
    switch astryx.spikeHooks ? astryx.native.icons[name] : nil {
    case .asset(let asset):
      Image(asset)
        .renderingMode(.template)
        .resizable()
        .interpolation(astryx.native.imageScaling == .pixelated ? .none : .high)
        .frame(width: size, height: size)
    case .system(let symbol):
      Image(systemName: symbol).font(.system(size: size * 0.8))
    case nil:
      Image(systemName: defaultSymbol).font(.system(size: size * 0.8))
    }
  }
}
