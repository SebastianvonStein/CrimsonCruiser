//
//  3DPathFunctions.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 12/2/24.
//

import Foundation
import SceneKit


//  █▄ █ ▄▀▄ █ █ ▀█▀ ▄▀▀ ▄▀▄ ▀█▀ ██▀     ▄▀▀ ▄▀▀ ██▀ █▄ █ ██▀     ▄▀▀ ▄▀▄ █▄ █ ▀█▀ ██▀ █▄ █ ▀█▀ ▄▀▀
//  █ ▀█ █▀█ ▀▄▀ ▄█▄ ▀▄█ █▀█  █  █▄▄     ▄██ ▀▄▄ █▄▄ █ ▀█ █▄▄     ▀▄▄ ▀▄▀ █ ▀█  █  █▄▄ █ ▀█  █  ▄██


/// This enum is used to categorize nodes into specific types, such as locations, pathways, or trees that are existing objects in the AnnotatedModel.scn
enum nodeType: String, CaseIterable, Codable {
    case locations = "locationNode"
    case pathways = "pathNode"
    case trees = "treeNode"
}

/// Recursively nagivates the AnnotatedModel.scn and adds the nodes to the webGraph based on a nodes name that is provided by the nodeType Enum.
/// > Used onAppear() to load nodes into WebGraph network!
func navigateSceneTreeToCreateWebGraphNodes(scene: SCNScene, webGraph: WebGraph,  nodeType: nodeType) {
    print("Started Navigating Scene Kit")
    // function for recursive traversal
    func traverseNodes(node: SCNNode) {
        // Check if the node name contains "locationNode"
        if let nodeName = node.name, nodeName.contains(nodeType.rawValue) {
            let graphNode = WebNode(name: node.name ?? "Unknown", xpos: Float(node.worldPosition.x), zpos: Float(node.worldPosition.z))
            webGraph.addNode(graphNode)
        }
        // Recursively traverse child nodes
        for child in node.childNodes {
            traverseNodes(node: child)
        }
    }
    // Start traversal from the root node
    traverseNodes(node: scene.rootNode)
}

/// Recursively nagivates the AnnotatedModel.scn and creates a sphere for all nodes that match a given name.
/// > Primarily used in DebugNodeGraph for establishing node connections. Not utilized in "active" build.
func navigateSceneTreeToFindNodes(scene: SCNScene, name: String, color: CIColor) {
    print("Started Navigating Scene Kit")
    // function for recursive traversal
    func traverseNodes(node: SCNNode) {
        // Check if the node name contains "locationNode" for example
        if let nodeName = node.name, nodeName.contains(name) {
            addSphere(scene: scene,
                      x: Float(node.worldPosition.x),
                      y: 0,
                      z: Float(node.worldPosition.z),
                      size: 5,
                      color: color,
                      name: node.name ?? "unknownNode")
        }
        // Recursively traverse child nodes
        for child in node.childNodes {
            traverseNodes(node: child)
        }
    }
    // Start traversal from the root node
    traverseNodes(node: scene.rootNode)
    print("Created SceneKit Spheres")
}


// ▄▀▄ █▀▄ █▀▄     ▄▀▀ ▄▀▀ ██▀ █▄ █ ██▀     ▄▀▀ ▄▀▄ █▄ █ ▀█▀ ██▀ █▄ █ ▀█▀
// █▀█ █▄▀ █▄▀     ▄██ ▀▄▄ █▄▄ █ ▀█ █▄▄     ▀▄▄ ▀▄▀ █ ▀█  █  █▄▄ █ ▀█  █


/// Draws all connections from an array of WebNodes to the 3D scene.
///
/// - Parameters:
///   - pathNodes: An array of `WebNode` objects representing the path to be drawn.
///   - scene: The `SCNScene` where the path should be rendered.
func drawPath(pathNodes: [WebNode], scene: SCNScene, lineWidth: CGFloat) {
    for i in 0..<(pathNodes.count - 1) {
        let startNode = pathNodes[i]
        let endNode = pathNodes[i + 1]
        // Create SCNVector3 positions for the start and end points
        let startPoint = SCNVector3(startNode.xpos, 0, startNode.zpos)
        let endPoint = SCNVector3(endNode.xpos, 0, endNode.zpos)
        // Draw a line between the start and end points
        addLineBetween(startPoint, and: endPoint, to: scene, lineWidth: lineWidth)
   }
}

/// Draws a 3D line between two SCNVector3 Coordinates within a 3D scene.
/// - Parameters:
///   - startPoint: The coordinates of where the line starts.
///   - endPoint: The coordinates of where the line ends.
///   - scene: The `SCNScene` where the connections should will be added..
///   - lineWidth: how big the line is.
func addLineBetween(_ startPoint: SCNVector3, and endPoint: SCNVector3, to scene: SCNScene, lineWidth: CGFloat = 2) {
    // Calculate the vector between the two points
    let vector = SCNVector3(
        x: endPoint.x - startPoint.x,
        y: endPoint.y - startPoint.y,
        z: endPoint.z - startPoint.z
    )
    
    // Calculate the length of the vector
    let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    
    // Create a cylinder to represent the line
    let cylinder = SCNCylinder(radius: lineWidth / 2, height: CGFloat(length))
    cylinder.radialSegmentCount = 16
    
    // Assign a material to the cylinder
    let material = SCNMaterial()
    #if os(macOS)
    material.diffuse.contents = NSColor(hue: 0.3, saturation: 0.8, brightness: 0.2, alpha: 1)
    //material.diffuse.contents = Color(hue: 0.3, saturation: 0.9, brightness: 0.60)
    #elseif os(iOS)
    material.diffuse.contents = UIColor(.black)
    #endif
    cylinder.firstMaterial = material
    
    // Create a node for the cylinder
    let lineNode = SCNNode(geometry: cylinder)
    
    // Position the cylinder between the two points
    lineNode.position = SCNVector3(
        x: (startPoint.x + endPoint.x) / 2,
        y: (startPoint.y + endPoint.y) / 2,
        z: (startPoint.z + endPoint.z) / 2
    )
    
    lineNode.name = "line"
    
    // Align the cylinder with the vector
    let direction = SCNVector3(
        x: vector.x / length,
        y: vector.y / length,
        z: vector.z / length
    )
    let up = SCNVector3(0, 1, 0) // Default up vector
    let crossProduct = SCNVector3(
        x: up.y * direction.z - up.z * direction.y,
        y: up.z * direction.x - up.x * direction.z,
        z: up.x * direction.y - up.y * direction.x
    )
    let dotProduct = up.x * direction.x + up.y * direction.y + up.z * direction.z
    let angle = acos(dotProduct)
    if angle > 0.001 {
        lineNode.rotation = SCNVector4(
            x: crossProduct.x,
            y: crossProduct.y,
            z: crossProduct.z,
            w: angle
        )
    }
    // Add the line node to the scene's root node
    scene.rootNode.addChildNode(lineNode)
}

/// Removes all lines generated by addLineBetween within the AnnotatedModel.scn
func removeAllLines(from scene: SCNScene) {
    // Enumerate through all child nodes of the root node
    scene.rootNode.enumerateChildNodes { (node, stop) in
        // Check if the node's name matches
        if node.name == "line" {
            // Remove the node from its parent
            node.removeFromParentNode()
        }
    }
}

/// Adds a 3D Sphere to a given coordinate in the AnnotatedModel.scn file.
func addSphere(scene: SCNScene, x: Float, y: Float, z: Float, size: Float, color: CIColor, name: String) {
    let sphere = SCNSphere(radius: CGFloat(size))
    sphere.segmentCount = 8
    sphere.materials.first?.lightingModel = .constant
#if os(macOS)
    sphere.materials.first?.diffuse.contents = NSColor(ciColor: color)
#elseif os(iOS)
    sphere.materials.first?.diffuse.contents = UIColor(ciColor: color)
    #endif
    let sphereNode = SCNNode(geometry: sphere)
    sphereNode.name = name
    sphereNode.castsShadow = false
#if os(macOS)
    sphereNode.position = SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
#elseif os(iOS)
    sphereNode.position = SCNVector3(x: Float(x), y: Float(y), z: Float(z))
#endif
    scene.rootNode.addChildNode(sphereNode)
}


// ▄▀▀ ▄▀▄ █▄ ▄█ ██▀ █▀█ ▄▀▄     ▄▀▄ █▄ █ ▀█▀ █▄ ▄█ ▄▀▄ ▀█▀ ▀█▀ ▄▀▄ █▄ █
// ▀▄▄ █▀█ █ ▀ █ █▄▄ █▀▄ █▀█     █▀█ █ ▀█ ▄█▄ █ ▀ █ █▀█  █  ▄█▄ ▀▄▀ █ ▀█

/// Moves the camera in a 3D scene to the midpoint between two nodes.
/// The function calculates the midpoint and adjusts the camera's position
/// based on the distance between the two nodes. It uses a smooth animation to
/// transition the camera.
/// - Parameters:
///   - depNode: The starting `WebNode`.
///   - desNode: The destination `WebNode`.
///   - scene: The `SCNScene` containing the camera.
/// ### Details
/// > Note: The animation duration is set to 0.5 seconds. Modify `SCNTransaction.animationDuration`
/// > to customize the duration.
///
/// - Warning: Ensure the camera node exists in the scene, or this function will fail gracefully
///   by printing an error.
func moveCamera(depNode: WebNode, desNode: WebNode, scene: SCNScene) {
    guard let cameraNode = scene.rootNode.childNode(withName: "cameraNode", recursively: true) else {
        print("Camera node not found")
        return
    }
    // Middle Cords
    let cameraCords: [Float] = middleCoordinates(x1: depNode.xpos, y1: depNode.zpos, x2: desNode.xpos, y2: desNode.zpos)
    // SCNPos
    let distance = distance(depNode, desNode)
#if os(macOS)
    let position = SCNVector3(x: CGFloat(cameraCords[0]), y: 1000 + CGFloat(((distance - 500)/3)), z: CGFloat(cameraCords[1] + 10))
#elseif os(iOS)
    let position = SCNVector3(x: Float(cameraCords[0]), y: -250 + Float(((distance - 500)/3)), z: Float(cameraCords[1] + 10))
#endif
    print(position)
    // Begin a transaction for animation
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0.5 // Duration of the animation in seconds
    // Set SCNCamera Pos
    cameraNode.worldPosition = position
    cameraNode.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
    // Comit Anim
    SCNTransaction.commit()
}


// █ █ ██▀ █   █▀▄ ██▀ █▀█ ▄▀▀
// █▀█ █▄▄ █▄▄ █▀  █▄▄ █▀▄ ▄██


/// Computes the midpoint between two 2D coordinates.
/// - Parameters:
///   - x1: The x-coordinate of the first point.
///   - y1: The y-coordinate of the first point.
///   - x2: The x-coordinate of the second point.
///   - y2: The y-coordinate of the second point.
/// - Returns: An array containing the x and y coordinates of the midpoint.
func middleCoordinates(x1: Float, y1: Float, x2: Float, y2: Float) -> [Float] {
    let midX = (x1 + x2) / 2
    let midY = (y1 + y2) / 2
    return [midX, midY]
}

/// Calculates the Euclidean distance between two nodes in 3D space.
/// - Parameters:
///   - nodeA: The first `WebNode`.
///   - nodeB: The second `WebNode`.
/// - Returns: A `Float` representing the distance between the two nodes.
func distance(_ nodeA: WebNode, _ nodeB: WebNode) -> Float {
    let dx = nodeA.xpos - nodeB.xpos
    let dz = nodeA.zpos - nodeB.zpos
    return sqrt(dx * dx + dz * dz)
}

/// Calculates the Euclidean distance between the car and its destination node
func CarDistance(carPos: SCNVector3, destNode: WebNode) -> CGFloat {
    let dx = carPos.x - CGFloat(destNode.xpos)
    let dz = carPos.z - CGFloat(destNode.zpos)
    return sqrt(dx * dx + dz * dz)
}

/// Prints all nodeNames found in the AnnotatedModel.scn
/// > Primarily used in DebugNodeGraph for establishing node connections. Not utilized in "active" build.
func printNodeNames(node: SCNNode) {
    let nodeName = node.name ?? "no name"
    print("Node name: \(nodeName)")

    for child in node.childNodes {
        printNodeNames(node: child) // Recursively call the function on each child node
    }
}



