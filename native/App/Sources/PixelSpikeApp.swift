// SPIKE app: shows one comparison screen, chosen by launch arguments,
// e.g. `-view login -variant proposed`. CI screenshots it in the simulator.

import SwiftUI

@main
struct PixelSpikeApp: App {
  var body: some Scene {
    WindowGroup {
      SpikeRoot(
        view: UserDefaults.standard.string(forKey: "view") ?? "components",
        variant: SpikeVariant(rawValue: UserDefaults.standard.string(forKey: "variant") ?? "") ?? .proposed
      )
    }
  }
}
