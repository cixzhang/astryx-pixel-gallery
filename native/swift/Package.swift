// swift-tools-version: 6.0
// Copyright (c) Meta Platforms, Inc. and affiliates.

// SPIKE copy of facebook/astryx PR 7981 (head 0f45bc2) packages/native/swift-ios-1,
// tests removed, with spike hooks in core/Spike and marked `SPIKE` in components.
// Astryx drawn in SwiftUI for iOS, generation 1 (AST-082, arm A). `core/`
// holds components; `templates/` holds page templates built from them. The
// macOS platform is declared only so `swift build` and `swift test` run on a
// Mac without a simulator; iOS is the target.

import PackageDescription

let package = Package(
  name: "AstryxSwiftIOS",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(name: "AstryxCore", targets: ["AstryxCore"]),
    .library(name: "AstryxTemplates", targets: ["AstryxTemplates"]),
  ],
  targets: [
    .target(name: "AstryxCore", path: "core"),
    .target(name: "AstryxTemplates", dependencies: ["AstryxCore"], path: "templates"),
  ]
)
