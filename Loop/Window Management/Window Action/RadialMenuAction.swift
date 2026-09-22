//
//  RadialMenuAction.swift
//  Loop
//
//  Created by Kai Azim on 2025-11-11.
//

import Defaults
import Foundation

/// A safe, identifiable wrapper around `ActionType`.
/// This avoids duplicate IDs when the same action or keybind appears more than once in the radial menu.
/// By giving each wrapped value its own custom ID, we keep identities stable across updates and
/// can correctly distinguish duplicate items within the menu.
struct RadialMenuAction: Identifiable, Codable, Hashable, Defaults.Serializable {
    let id: UUID
    var type: ActionType

    /// Used to describe the "link" to an existing keybind, or to contain a WindowAction.
    enum ActionType: Identifiable, Codable, Hashable {
        case custom(WindowAction)
        case keybindReference(UUID)

        var id: UUID {
            switch self {
            case let .custom(windowAction):
                windowAction.id
            case let .keybindReference(id):
                id
            }
        }

        var resolvedAction: WindowAction? {
            switch self {
            case let .custom(windowAction):
                windowAction
            case let .keybindReference(id):
                if let action = Defaults[.keybinds].first(where: { $0.id == id }) {
                    action
                } else {
                    nil
                }
            }
        }

        var isKeybindReference: Bool {
            switch self {
            case .custom:
                false
            case .keybindReference:
                true
            }
        }
    }

    private init(id: UUID, type: ActionType) {
        self.id = id
        self.type = type
    }

    static func custom(_ action: WindowAction) -> Self {
        self.init(
            id: .init(),
            type: .custom(action)
        )
    }

    static func keybindReference(_ id: UUID) -> Self {
        self.init(
            id: .init(),
            type: .keybindReference(id)
        )
    }

    // MARK: Computed Helpers

    var associatedActionId: UUID {
        type.id
    }

    var resolved: WindowAction? {
        type.resolvedAction
    }
}

extension RadialMenuAction {
    /// A window action covering part of the screen, in percentages of the available bounds.
    private static func cell(
        _ name: String,
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) -> WindowAction {
        WindowAction(
            .custom,
            keybind: [],
            name: name,
            unit: .percentage,
            width: width,
            height: height,
            xPoint: x,
            yPoint: y,
            positionMode: .coordinates,
            sizeMode: .custom
        )
    }

    /// Twelve segments of 30 degrees, laid out as a grid of three columns and two rows.
    /// The segments closer to the vertical axis hold the wider zones, which matches where their centers are.
    static let defaultRadialMenuActions: [RadialMenuAction] = [
        .custom(
            WindowAction(
                "Top Center",
                cycle: [
                    cell("Top Center Third", x: 33.333, y: 0, width: 33.334, height: 50),
                    cell("Top Center Half", x: 25, y: 0, width: 50, height: 50),
                    cell("Top Center Two Thirds", x: 16.667, y: 0, width: 66.666, height: 50)
                ]
            )
        ),
        .custom(WindowAction(.topRightQuarter)),
        .custom(
            WindowAction(
                "Top Right Third",
                cycle: [
                    cell("Top Right Third", x: 66.667, y: 0, width: 33.333, height: 50),
                    cell("Top Right Two Thirds", x: 33.333, y: 0, width: 66.667, height: 50)
                ]
            )
        ),
        .custom(
            WindowAction(
                .init(localized: "Right Cycle"),
                cycle: [.init(.rightHalf), .init(.rightThird), .init(.rightTwoThirds)]
            )
        ),
        .custom(
            WindowAction(
                "Bottom Right Third",
                cycle: [
                    cell("Bottom Right Third", x: 66.667, y: 50, width: 33.333, height: 50),
                    cell("Bottom Right Two Thirds", x: 33.333, y: 50, width: 66.667, height: 50)
                ]
            )
        ),
        .custom(WindowAction(.bottomRightQuarter)),
        .custom(
            WindowAction(
                "Bottom Center",
                cycle: [
                    cell("Bottom Center Third", x: 33.333, y: 50, width: 33.334, height: 50),
                    cell("Bottom Center Half", x: 25, y: 50, width: 50, height: 50),
                    cell("Bottom Center Two Thirds", x: 16.667, y: 50, width: 66.666, height: 50)
                ]
            )
        ),
        .custom(WindowAction(.bottomLeftQuarter)),
        .custom(
            WindowAction(
                "Bottom Left Third",
                cycle: [
                    cell("Bottom Left Third", x: 0, y: 50, width: 33.333, height: 50),
                    cell("Bottom Left Two Thirds", x: 0, y: 50, width: 66.667, height: 50)
                ]
            )
        ),
        .custom(
            WindowAction(
                .init(localized: "Left Cycle"),
                cycle: [.init(.leftHalf), .init(.leftThird), .init(.leftTwoThirds)]
            )
        ),
        .custom(
            WindowAction(
                "Top Left Third",
                cycle: [
                    cell("Top Left Third", x: 0, y: 0, width: 33.333, height: 50),
                    cell("Top Left Two Thirds", x: 0, y: 0, width: 66.667, height: 50)
                ]
            )
        ),
        .custom(WindowAction(.topLeftQuarter)),
        .custom(
            WindowAction(
                "\(WindowDirection.maximize.name) + \(WindowDirection.macOSCenter.name)",
                cycle: [
                    .init(.maximize),
                    .init(.macOSCenter)
                ]
            )
        )
    ]

    static var userConfiguredActions: [RadialMenuAction] {
        Defaults[.enableRadialMenuCustomization] ? Defaults[.radialMenuActions] : defaultRadialMenuActions
    }
}
