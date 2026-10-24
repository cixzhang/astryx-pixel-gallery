// Copyright (c) Meta Platforms, Inc. and affiliates.

import SwiftUI

/// Core's `Banner` statuses.
public enum AstryxBannerStatus: String, CaseIterable, Sendable {
  case info
  case warning
  case error
  case success

  /// The shared icon name (SPIKE, H6) and the SF Symbol it defaults to.
  var iconName: String { rawValue }
  var symbol: String {
    switch self {
    case .info: "info.circle.fill"
    case .warning: "exclamationmark.triangle.fill"
    case .error: "exclamationmark.circle.fill"
    case .success: "checkmark.circle.fill"
    }
  }

  var groundToken: String {
    switch self {
    case .info: "color-accent-muted"
    case .warning: "color-warning-muted"
    case .error: "color-error-muted"
    case .success: "color-success-muted"
    }
  }

  var iconToken: String {
    switch self {
    case .info: "color-accent"
    case .warning: "color-warning"
    case .error: "color-error"
    case .success: "color-success"
    }
  }
}

/// A message about the page or a section of it. The status sets the color
/// and icon only; the title must say what happened, because the icon is
/// decorative to VoiceOver.
public struct AstryxBanner: View {
  let status: AstryxBannerStatus
  let title: String
  let description: String?
  @Environment(\.astryx) private var astryx

  public init(status: AstryxBannerStatus, title: String, description: String? = nil) {
    self.status = status
    self.title = title
    self.description = description
  }

  public var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: astryx.space(2)) {
      // SPIKE (H6): resolve the shared icon name through the theme.
      AstryxIcon(status.iconName, default: status.symbol, size: 20)  // core Icon md
        .foregroundStyle(astryx.color(status.iconToken))
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: astryx.space(1)) {
        AstryxText(title, weight: .semibold)
        if let description {
          AstryxText(description, color: .secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(astryx.space(3))
    // SPIKE (H4, H5): theme shape and border.
    .background(
      astryx.surfaceShape("banner", radius: "radius-container", 12)
        .fill(astryx.color(status.groundToken))
    )
    .overlay(astryx.surfaceBorder("banner", radius: "radius-container", 12, color: nil))
    .accessibilityElement(children: .combine)
  }
}
