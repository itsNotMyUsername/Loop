//
//  DirectionSelectorSquareSegment.swift
//  Loop
//
//  Created by Kai Azim on 2023-08-19.
//

import SwiftUI

struct DirectionSelectorSquareSegment: View {
    var angle: Double = .zero

    /// Half of the angular width of the highlight, so that it matches one radial menu segment.
    let halfAngleSpan: Double
    let radialMenuCornerRadius: CGFloat
    let radialMenuThickness: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radialMenuCornerRadius)
                .trim(
                    from: Angle(degrees: angle - halfAngleSpan).normalized().degrees / 360.0,
                    to: Angle(degrees: angle + halfAngleSpan).normalized().degrees / 360.0
                )
                .stroke(.white, lineWidth: radialMenuThickness * 2)

            RoundedRectangle(cornerRadius: radialMenuCornerRadius)
                .trim(
                    from: Angle(degrees: angle - 180 - halfAngleSpan).normalized().degrees / 360.0,
                    to: Angle(degrees: angle - 180 + halfAngleSpan).normalized().degrees / 360.0
                )
                .stroke(.white, lineWidth: radialMenuThickness * 2)
                .rotationEffect(.degrees(180))
        }
    }
}
