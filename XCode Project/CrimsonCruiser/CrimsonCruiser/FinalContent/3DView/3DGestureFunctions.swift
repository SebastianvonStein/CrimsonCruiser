//
//  3DGenericFunctions.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 12/2/24.
//

import Foundation
import SceneKit

/// > Primarily used in DebugNodeGraph for establishing node connections. Not utilized in "active" build.
struct GestureHandler {
    #if os(iOS)
    static func handleTap(_ gestureRecognize: UIGestureRecognizer) -> String? {
        guard let sceneView = gestureRecognize.view as? SCNView else { return nil }
        let location = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: [:])

        if let hit = hitResults.first {
            let node = hit.node
            print("Tapped node name: \(node.name ?? "Unknown")")
            return node.name
        }
        return nil
    }
    #elseif os(macOS)
    static func handleTap(_ gestureRecognize: NSClickGestureRecognizer) -> String? {
        guard let sceneView = gestureRecognize.view as? SCNView else { return nil }
        let location = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: [:])

        if let hit = hitResults.first {
            let node = hit.node
            print("Tapped node name: \(node.name ?? "Unknown")")
            return node.name
        }
        return nil
    }
    #endif
}
