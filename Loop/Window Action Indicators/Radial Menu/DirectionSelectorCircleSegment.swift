//
//  DirectionSelectorCircleSegment.swift
//  Loop
//
//  Created by Kai Azim on 2023-08-19.
//

import SwiftUI

struct DirectionSelectorCircleSegment: Shape {
    var angle: Double = .zero

    /// Half of the angular width of the highlight, so that it matches one radial menu segment.
    let halfAngleSpan: Double
    let radialMenuSize: CGFloat

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func path(in _: CGRect) -> Path {
        var path = Path()

        path.move(
            to: CGPoint(
                x: radialMenuSize / 2,
                y: radialMenuSize / 2
            )
        )
        path.addArc(
            center: CGPoint(
                x: radialMenuSize / 2,
                y: radialMenuSize / 2
            ),
            radius: radialMenuSize,
            startAngle: .degrees(angle - halfAngleSpan),
            endAngle: .degrees(angle + halfAngleSpan),
            clockwise: false
        )

        return path
    }
}
