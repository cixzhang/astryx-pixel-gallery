// SPIKE — not Astryx API. Pixel corners for proposed `corners: 'stepped'`.

import SwiftUI

/// A rectangle whose corners are staircases of square steps, as the web
/// pixel theme's clip-path draws them: at each corner, `steps` steps of
/// `step` points, each going in (along the edge) and then down.
public struct SteppedRectangle: Shape {
  public var step: CGFloat
  public var steps: Int

  public init(step: CGFloat, steps: Int) {
    self.step = step
    self.steps = steps
  }

  public func path(in rect: CGRect) -> Path {
    Path { path in
      let points = SteppedRectangle.outline(rect, step: step, steps: steps)
      guard let first = points.first else { return }
      path.move(to: first)
      for point in points.dropFirst() { path.addLine(to: point) }
      path.closeSubpath()
    }
  }

  /// The outline, clockwise from the top edge. Each corner starts `steps`
  /// steps before the corner along the incoming edge `a`, then repeats
  /// "turn along `b`, then along `a`" once per step.
  static func outline(_ rect: CGRect, step: CGFloat, steps: Int) -> [CGPoint] {
    let n = max(0, min(steps, Int(min(rect.width, rect.height) / (2 * max(step, 0.5)))))
    let corners: [(corner: CGPoint, a: CGVector, b: CGVector)] = [
      (CGPoint(x: rect.maxX, y: rect.minY), CGVector(dx: 1, dy: 0), CGVector(dx: 0, dy: 1)),
      (CGPoint(x: rect.maxX, y: rect.maxY), CGVector(dx: 0, dy: 1), CGVector(dx: -1, dy: 0)),
      (CGPoint(x: rect.minX, y: rect.maxY), CGVector(dx: -1, dy: 0), CGVector(dx: 0, dy: -1)),
      (CGPoint(x: rect.minX, y: rect.minY), CGVector(dx: 0, dy: -1), CGVector(dx: 1, dy: 0)),
    ]
    var points: [CGPoint] = []
    for (corner, a, b) in corners {
      var p = CGPoint(x: corner.x - a.dx * CGFloat(n) * step, y: corner.y - a.dy * CGFloat(n) * step)
      points.append(p)
      for _ in 0..<n {
        p = CGPoint(x: p.x + b.dx * step, y: p.y + b.dy * step)
        points.append(p)
        p = CGPoint(x: p.x + a.dx * step, y: p.y + a.dy * step)
        points.append(p)
      }
    }
    return points
  }
}

/// The stepped border ring: the outer staircase minus an inner staircase
/// inset by the border width with one step fewer. That is the web theme's
/// clip-path + inset ring + corner blocks, drawn as one even-odd shape.
public struct SteppedFrame: Shape {
  public var step: CGFloat
  public var steps: Int
  public var width: CGFloat

  public init(step: CGFloat, steps: Int, width: CGFloat) {
    self.step = step
    self.steps = steps
    self.width = width
  }

  public func path(in rect: CGRect) -> Path {
    var path = SteppedRectangle(step: step, steps: steps).path(in: rect)
    path.addPath(
      SteppedRectangle(step: step, steps: max(0, steps - 1))
        .path(in: rect.insetBy(dx: width, dy: width))
    )
    return path
  }
}
