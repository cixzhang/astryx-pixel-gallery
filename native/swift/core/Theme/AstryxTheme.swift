// Copyright (c) Meta Platforms, Inc. and affiliates.
// Adapted from github.com/ejc3/astryx-swift (MIT).

import SwiftUI

/// One mode of a theme, resolved: colors as `#RRGGBBAA` and sizes in points,
/// keyed by core's token names without the leading `--`.
public struct AstryxTokens: Equatable, Sendable {
  public var colors: [String: String]
  public var sizes: [String: Double]
  // SPIKE (PR 8031 G3/G6): font stacks as ordered family lists.
  public var fonts: [String: [String]]

  public init(colors: [String: String], sizes: [String: Double], fonts: [String: [String]] = [:]) {
    self.colors = colors
    self.sizes = sizes
    self.fonts = fonts
  }
}

/// A theme's light and dark tokens. `AstryxTheme.default` is core's default
/// theme, generated from core's own resolver.
public struct AstryxTheme: Equatable, Sendable {
  public var light: AstryxTokens
  public var dark: AstryxTokens
  // SPIKE (PR 8031 OQ3): the native theme, resolved for iOS.
  public var native: AstryxNativeIntent

  public init(light: AstryxTokens, dark: AstryxTokens, native: AstryxNativeIntent = .none) {
    self.light = light
    self.dark = dark
    self.native = native
  }

  public static let `default` = AstryxTheme(
    light: .defaultLight,
    dark: .defaultDark
  )
}

/// The tokens a component paints with: one mode of the theme, grown by the
/// person's Dynamic Type setting. Components read every color, size, and font
/// from here, never from a constant of their own.
public struct AstryxStyle: Sendable {
  public let tokens: AstryxTokens
  /// How much Dynamic Type grows text at the person's setting (1 at Large).
  public let textScale: CGFloat
  // SPIKE: native intent, the screen's scale, and a switch that turns every
  // spike hook off so the same build renders swift-ios-1 as it is today.
  public let native: AstryxNativeIntent
  public let displayScale: CGFloat
  public let spikeHooks: Bool

  public init(
    tokens: AstryxTokens,
    textScale: CGFloat = 1,
    native: AstryxNativeIntent = .none,
    displayScale: CGFloat = 2,
    spikeHooks: Bool = true
  ) {
    self.tokens = tokens
    self.textScale = textScale
    self.native = native
    self.displayScale = displayScale
    self.spikeHooks = spikeHooks
  }

  /// A token color. A token the theme does not define draws clear, so a
  /// missing token shows up in review instead of a guessed color.
  public func color(_ token: String) -> Color {
    guard let hex = tokens.colors[token] else { return .clear }
    return Color(astryxHex: hex)
  }

  /// A token size in points, or `fallback` when the theme does not define it.
  public func size(_ token: String, _ fallback: CGFloat) -> CGFloat {
    tokens.sizes[token].map { CGFloat($0) } ?? fallback
  }

  /// A step on the spacing ladder: `space(4)` reads `spacing-4`.
  public func space(_ step: Int) -> CGFloat {
    size("spacing-\(step)", CGFloat(step) * 4)
  }

  /// A token font size grown by Dynamic Type.
  public func fontSize(_ token: String, _ fallback: CGFloat) -> CGFloat {
    // SPIKE (hook H3, proposed `textGrid`): snap to the typeface's grid.
    snapToTextGrid(size(token, fallback) * textScale)
  }

  /// A font at a token size and a token weight. SPIKE (hook H1, PR 8031 G7):
  /// the family comes from a `font-family-*` token when the app has it.
  public func font(
    size token: String,
    _ fallback: CGFloat,
    weight: String,
    family: String = "font-family-body"
  ) -> Font {
    themedFont(size: fontSize(token, fallback), weight: fontWeight(size(weight, 400)), family: family)
  }

  func fontWeight(_ value: CGFloat) -> Font.Weight {
    switch value {
    case ..<350: .light
    case 350..<450: .regular
    case 450..<550: .medium
    case 550..<650: .semibold
    case 650..<750: .bold
    default: .heavy
    }
  }
}

extension Color {
  /// A color from `#RRGGBBAA`, the form the generated tokens use. `#RRGGBB`
  /// and `#RGB` also read; anything else is clear.
  public init(astryxHex hex: String) {
    var digits = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
    if digits.count == 3 { digits = digits.map { "\($0)\($0)" }.joined() }
    if digits.count == 6 { digits += "FF" }
    guard digits.count == 8, let value = UInt32(digits, radix: 16) else {
      self = .clear
      return
    }
    self.init(
      .sRGB,
      red: Double((value >> 24) & 0xFF) / 255,
      green: Double((value >> 16) & 0xFF) / 255,
      blue: Double((value >> 8) & 0xFF) / 255,
      opacity: Double(value & 0xFF) / 255
    )
  }
}

/// Dynamic Type's growth for body-sized text, as Apple's Body style grows
/// (17 pt at Large).
func astryxTextScale(for size: DynamicTypeSize) -> CGFloat {
  switch size {
  case .xSmall: 0.82
  case .small: 0.88
  case .medium: 0.94
  case .large: 1
  case .xLarge: 1.12
  case .xxLarge: 1.23
  case .xxxLarge: 1.35
  case .accessibility1: 1.6
  case .accessibility2: 1.9
  case .accessibility3: 2.35
  case .accessibility4: 2.75
  case .accessibility5: 3.1
  @unknown default: 1
  }
}

private struct AstryxStyleKey: EnvironmentKey {
  static let defaultValue = AstryxStyle(tokens: .defaultLight)
}

// SPIKE: lets one build render with and without the spike hooks.
private struct AstryxSpikeHooksKey: EnvironmentKey {
  static let defaultValue = true
}

extension EnvironmentValues {
  public var astryxSpikeHooks: Bool {
    get { self[AstryxSpikeHooksKey.self] }
    set { self[AstryxSpikeHooksKey.self] = newValue }
  }
}

extension EnvironmentValues {
  /// The style components paint with. `astryxTheme(_:)` sets it; without it,
  /// components paint with core's default light tokens.
  public var astryx: AstryxStyle {
    get { self[AstryxStyleKey.self] }
    set { self[AstryxStyleKey.self] = newValue }
  }
}

private struct AstryxThemeModifier: ViewModifier {
  let theme: AstryxTheme
  @Environment(\.colorScheme) private var scheme
  @Environment(\.dynamicTypeSize) private var typeSize
  @Environment(\.displayScale) private var displayScale
  @Environment(\.astryxSpikeHooks) private var spikeHooks

  func body(content: Content) -> some View {
    content.environment(
      \.astryx,
      AstryxStyle(
        tokens: scheme == .dark ? theme.dark : theme.light,
        textScale: astryxTextScale(for: typeSize),
        native: theme.native,
        displayScale: displayScale,
        spikeHooks: spikeHooks
      )
    )
  }
}

extension View {
  /// Paints this subtree with a theme, following the color scheme and the
  /// person's text size.
  public func astryxTheme(_ theme: AstryxTheme = .default) -> some View {
    modifier(AstryxThemeModifier(theme: theme))
  }
}
