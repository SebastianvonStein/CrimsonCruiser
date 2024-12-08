//
//  NodeClass.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 11/16/24.
//

/*
 ▄▀▀ █▀▄ █ █▄ ▄█ ▄▀▀ ▄▀▄ █▄ █
 ▀▄▄ █▀▄ █ █ ▀ █ ▄██ ▀▄▀ █ ▀█
 
 ▄▀▀ █▀▄ █ █ █ ▄▀▀ ██▀ █▀▄
 ▀▄▄ █▀▄ ▀▄█ █ ▄██ █▄▄ █▀▄
 
 - - - - - - - - - - - - - - - -
 
 █▄ █ ▄▀▄ █▀▄ ██▀   █▄ █ ██▀ ▀█▀ █   █ ▄▀▄ █▀▄ █▄▀
 █ ▀█ ▀▄▀ █▄▀ █▄▄   █ ▀█ █▄▄  █  ▀▄▀▄▀ ▀▄▀ █▀▄ █ █
 */

import Foundation
import SceneKit
import SwiftData

/// A node in a web graph, representing a point with its own UUID and 2D coordinates.
class WebNode: Identifiable {
    let id: UUID = UUID()
    var name: String
    var xpos: Float
    var zpos: Float
    var setupdone: Bool = false /// Was only used for testing, debugging and initial development. Currently unused.
    
    /// Initializes a new `WebNode` instance.
    ///
    /// - Parameters:
    ///   - name: The name of the node.
    ///   - xpos: The x-coordinate of the node.
    ///   - zpos: The z-coordinate of the node.
    ///   - setupdone: Whether the node setup is complete. Defaults to `false`. Currenlty unused.
    init(name: String, xpos: Float, zpos: Float, setupdone: Bool = false) {
        self.name = name
        self.xpos = xpos
        self.zpos = zpos
        self.setupdone = setupdone
    }
}

/// The WebGraph structure that manages multiple`WebNode` instances, their connections, and all relevant functions for manipulating the node data.
class WebGraph: ObservableObject {
    
    /// The nodes in the graph.
    @Published var nodes: [WebNode] = []
    
    /// The connections between nodes, represented as a dictionary where each key is a node ID,
    /// and the value is an array of connected node IDs.
    @Published var connections: [UUID: [UUID]] = [:]
    
    /// The name of the currently selected node.
    /// > **Not utilized in "active" build**. Primarily used in DebugNodeGraph for establishing node connections.
    @Published var selectedNodeName: String = ""
    
    /// The names of secondary nodes selected for connection.
    /// > Primarily used in DebugNodeGraph for establishing node connections. Not utilized in "active" build.
    @Published var secondSelectedNodeName: [String] = []
    
    // MARK: - Node Management Functions
    
    /// Adds a new node to the graph and initializes its connections.
    /// - Parameter node: The `WebNode` to add to the graph.
    func addNode(_ node: WebNode) {
        nodes.append(node)
        connections[node.id] = []
    }
    
    /// Connects two nodes bidirectionally.
    /// - Parameters:
    ///   - node1: The first node to connect.
    ///   - node2: The second node to connect.
    func connect(_ node1: WebNode, _ node2: WebNode) {
        connections[node1.id]?.append(node2.id)
        connections[node2.id]?.append(node1.id) // For bidirectional connection
    }
    
    /// Retrieves all nodes connected to a given node.
    /// - Parameter node: The `WebNode` for which to retrieve connections.
    /// - Returns: An array of `WebNode` instances connected to the given node.
    func getConnections(for node: WebNode) -> [WebNode] {
        guard let connectedIds = connections[node.id] else { return [] }
        return nodes.filter { connectedIds.contains($0.id) }
    }
    
    /// Finds a node by its name.
    /// - Parameter name: The name of the node to search for.
    /// - Returns: The `WebNode` with the matching name, or `nil` if no match is found.
    func getNode(name: String) -> WebNode? {
        return nodes.first(where: { $0.name == name })
    }
    
    /// Connects the currently selected node with nodes in the secondary selection array.
    /// Clears `selectedNodeName` and `secondSelectedNodeName` after connecting.
    /// > Primarily used in DebugNodeGraph for establishing node connections. Not utilized in "active" build.
    func connectWithArray() {
        for target in secondSelectedNodeName {
            //print(target)
            print("connect(getNode(name: \"\(selectedNodeName.description)\")!, getNode(name: \"\(target)\")!)")
            connect(getNode(name: selectedNodeName)!, getNode(name: target)!)
        }
        selectedNodeName = ""
        secondSelectedNodeName = []
    }

    /// Connects two nodes by their names.
    /// - Parameters:
    ///   - node1: The name of the first node.
    ///   - node2: The name of the second node.
    func connectWithNames(node1: String, node2: String) {
        let node1w = getNode(name: node1)
        let node2w = getNode(name: node2)
        connect(node1w!, node2w!)
    }
    
    /// Draws lines representing connections between nodes in the graph within a 3D scene.
    /// - Parameters:
    ///   - webGraph: The graph containing nodes and connections.
    ///   - scene: The `SCNScene` where the connections should will be added..
    func drawConnections(in webGraph: WebGraph, scene: SCNScene) {
        for (nodeID, connectedNodeIDs) in webGraph.connections {
            guard let centralNode = webGraph.nodes.first(where: { $0.id == nodeID }) else { continue }
            let startVector = SCNVector3(centralNode.xpos, 0.5, centralNode.zpos)
            
            for connectedNodeID in connectedNodeIDs {
                guard let connectedNode = webGraph.nodes.first(where: { $0.id == connectedNodeID }) else { continue }
                let endVector = SCNVector3(connectedNode.xpos, 0.5, connectedNode.zpos)
    
                addLineBetween(startVector, and: endVector, to: scene)
            }
        }
    }
    

    /*
     // MARK: Pathfinding!
     █▀▄ ▀█▀   █ █▄▀ ▄▀▀ ▀█▀ █▀█ ▄▀▄ ▄▀▀     ▄▀▄ █   ▄▀▀ ▄▀▄ █▀█ ▀█▀ ▀█▀ █ █ █▄ ▄█
     █▄▀ ▄█▄ ▀▄█ █▀▄ ▄██  █  █▀▄ █▀█ ▄██     █▀█ █▄▄ ▀▄█ ▀▄▀ █▀▄ ▄█▄  █  █▀█ █ ▀ █
    */
    /// Finds the shortest path between two nodes in the graph using Dijkstra's algorithm.
    ///
    /// The function computes the shortest path from the `start` node to the `end` node
    /// based on the distances ( weights ) it computes at runtime of the  connected  nodes.
    /// - Parameters:
    ///   - start: The starting `WebNode` for the path.
    ///   - end: The destination `WebNode` for the path.
    ///
    /// - Returns: An array of `WebNode` instances representing the shortest path from
    ///   `start` to `end`. If no path exists, returns an empty array.
    ///
    /// ### Example
    /// ```swift
    /// let path = graph.findPath(start: nodeA, end: nodeB)
    /// // print's the path nodes in their respective order: ["NodeA", "NodeX", "NodeB"]
    /// print(path.map { $0.name })
    /// ```
    /// ### Details
    /// The function uses Dijkstra's algorithm to calculate the shortest path:
    /// - Each node in the graph is assigned a tentative distance, initially set to infinity
    ///   (`Float.greatestFiniteMagnitude`) except for the `start` node, which is set to 0.
    /// - Nodes are visited in order of their tentative distance, and the algorithm updates
    ///   the shortest paths to their neighbors.
    func findPath(start: WebNode, end: WebNode) -> [WebNode] {
        var distances: [UUID: Float] = [:] // Distance from start to node
        var previousNodes: [UUID: UUID] = [:] // Previous node in optimal path
        var unvisited: Set<UUID> = Set(nodes.map { $0.id }) // All nodes are initially unvisited

        // Initialize distances between nodes.
        for node in nodes {
            distances[node.id] = Float.greatestFiniteMagnitude
        }
        distances[start.id] = 0

        while !unvisited.isEmpty {
            // Find the unvisited node with the smallest distance
            guard let currentId = unvisited.min(by: { distances[$0]! < distances[$1]! }) else {
                break
            }
            unvisited.remove(currentId)

            if currentId == end.id {
                // Destination reached, reconstruct path
                var path: [WebNode] = []
                var current = currentId
                while true {
                    if let node = nodes.first(where: { $0.id == current }) {
                        path.append(node)
                        if let prev = previousNodes[current] {
                            current = prev
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
                return path.reversed()
            }

            guard let currentNode = nodes.first(where: { $0.id == currentId }) else { continue }

            // For each neighbor of currentNode
            if let neighborIds = connections[currentNode.id] {
                for neighborId in neighborIds {
                    guard let neighborNode = nodes.first(where: { $0.id == neighborId }) else { continue }

                    // Calculate tentative distance
                    let tentativeDistance = distances[currentId]! + distance(currentNode, neighborNode)

                    if tentativeDistance < distances[neighborId]! {
                        // Update distance and path
                        distances[neighborId] = tentativeDistance
                        previousNodes[neighborId] = currentId
                    }
                }
            }
        }

        // No path found
        return []
    
   }

    
    /*
    // MARK: Initialize Connected Network
    ▄▀▀ ▀█▀ ▄▀▄ █▀▄ ██▀ █▀▄   █▄ █ ██▀ ▀█▀ █   █ ▄▀▄ █▀▄ █▄▀
    ▄██  █  ▀▄▀ █▀▄ █▄▄ █▄▀   █ ▀█ █▄▄  █  ▀▄▀▄▀ ▀▄▀ █▀▄ █ █
    */

    /// Generates connections between nodes already contained in the AnnotatedModel.scn SceneKit File.
    /// This code was generated semi-automatically by a second application I wrote - DebugNodeGraph.
    ///
    /// DebugNodeGraph allowed me to manually select nodes in the 3D Viewport, then select the connections.
    /// After doing the manual input in a 3D Viewport, I wrote the code for DebugNodeGraph to automatically generated the following Connection initalization list code to preload those same connections when starting the app
    ///
    /// I briefly tried storing this data in an SQL and fetching it from there but was unable to get that to work....
    func preload() {
        connect(getNode(name: "pathNode_11")!, getNode(name: "pathNode_10")!)
        connect(getNode(name: "pathNode_11")!, getNode(name: "pathNode_63")!)
        connect(getNode(name: "pathNode_11")!, getNode(name: "pathNode_12")!)
        connect(getNode(name: "pathNode_11")!, getNode(name: "pathNode_71")!)
        
        connect(getNode(name: "pathNode_130")!, getNode(name: "pathNode_126")!)
        connect(getNode(name: "pathNode_130")!, getNode(name: "pathNode_129")!)
        
        connect(getNode(name: "pathNode_125")!, getNode(name: "pathNode_126")!)
        connect(getNode(name: "pathNode_125")!, getNode(name: "pathNode_127")!)
        connect(getNode(name: "pathNode_125")!, getNode(name: "locationNode_40")!)
        connect(getNode(name: "pathNode_125")!, getNode(name: "pathNode_121")!)
        
        connect(getNode(name: "pathNode_126")!, getNode(name: "pathNode_127")!)
        connect(getNode(name: "pathNode_126")!, getNode(name: "pathNode_129")!)
        
        connect(getNode(name: "pathNode_127")!, getNode(name: "pathNode_54")!)
        
        connect(getNode(name: "pathNode_129")!, getNode(name: "pathNode_128")!)
        
        connect(getNode(name: "pathNode_54")!, getNode(name: "pathNode_128")!)
        connect(getNode(name: "pathNode_54")!, getNode(name: "pathNode_58")!)
        
        connect(getNode(name: "pathNode_128")!, getNode(name: "locationNode_15")!)
        connect(getNode(name: "pathNode_128")!, getNode(name: "locationNode_14")!)
        connect(getNode(name: "pathNode_128")!, getNode(name: "pathNode_53")!)
        
        connect(getNode(name: "pathNode_58")!, getNode(name: "pathNode_57")!)
        connect(getNode(name: "pathNode_58")!, getNode(name: "pathNode_6")!)
        connect(getNode(name: "pathNode_58")!, getNode(name: "pathNode_5")!)
        
        connect(getNode(name: "pathNode_57")!, getNode(name: "locationNode_12")!)
        connect(getNode(name: "pathNode_57")!, getNode(name: "pathNode_56")!)
        
        connect(getNode(name: "pathNode_56")!, getNode(name: "locationNode_12")!)
        connect(getNode(name: "pathNode_56")!, getNode(name: "pathNode_6")!)
        connect(getNode(name: "pathNode_56")!, getNode(name: "pathNode_55")!)
        
        connect(getNode(name: "pathNode_6")!, getNode(name: "pathNode_7")!)
        connect(getNode(name: "pathNode_6")!, getNode(name: "pathNode_8")!)
        connect(getNode(name: "pathNode_6")!, getNode(name: "pathNode_5")!)
        
        connect(getNode(name: "pathNode_8")!, getNode(name: "locationNode_55")!)
        connect(getNode(name: "pathNode_8")!, getNode(name: "pathNode_9")!)
        connect(getNode(name: "pathNode_8")!, getNode(name: "pathNode_55")!)
        
        connect(getNode(name: "pathNode_55")!, getNode(name: "pathNode_120")!)
        
        connect(getNode(name: "pathNode_120")!, getNode(name: "pathNode_121")!)
        connect(getNode(name: "pathNode_120")!, getNode(name: "pathNode_122")!)
        
        connect(getNode(name: "pathNode_121")!, getNode(name: "locationNode_41")!)
        connect(getNode(name: "pathNode_121")!, getNode(name: "locationNode_40")!)
        connect(getNode(name: "pathNode_121")!, getNode(name: "locationNode_42")!)
        connect(getNode(name: "pathNode_121")!, getNode(name: "pathNode_122")!)
        
        connect(getNode(name: "pathNode_122")!, getNode(name: "locationNode_43")!)
        connect(getNode(name: "pathNode_122")!, getNode(name: "pathNode_123")!)
        
        connect(getNode(name: "pathNode_5")!, getNode(name: "pathNode_4")!)
        
        connect(getNode(name: "pathNode_3")!, getNode(name: "pathNode_61")!)
        connect(getNode(name: "pathNode_3")!, getNode(name: "pathNode_17")!)
        connect(getNode(name: "pathNode_3")!, getNode(name: "pathNode_2")!)
        connect(getNode(name: "pathNode_3")!, getNode(name: "pathNode_5")!)
        
        connect(getNode(name: "pathNode_59")!, getNode(name: "pathNode_5")!)
        connect(getNode(name: "pathNode_59")!, getNode(name: "locationNode_7")!)
        connect(getNode(name: "pathNode_59")!, getNode(name: "pathNode_60")!)
        
        connect(getNode(name: "pathNode_60")!, getNode(name: "pathNode_59")!)
        connect(getNode(name: "pathNode_60")!, getNode(name: "locationNode_7")!)
        connect(getNode(name: "pathNode_60")!, getNode(name: "pathNode_61")!)
        
        connect(getNode(name: "pathNode_61")!, getNode(name: "pathNode_62")!)
        connect(getNode(name: "pathNode_61")!, getNode(name: "pathNode_17")!)
        
        connect(getNode(name: "pathNode_2")!, getNode(name: "pathNode_4")!)
        connect(getNode(name: "pathNode_2")!, getNode(name: "pathNode_1")!)
        
        connect(getNode(name: "pathNode_20")!, getNode(name: "pathNode_2")!)
        connect(getNode(name: "pathNode_20")!, getNode(name: "pathNode_19")!)
        connect(getNode(name: "pathNode_20")!, getNode(name: "pathNode_21")!)
        
        connect(getNode(name: "pathNode_1")!, getNode(name: "locationNode_39")!)
        
        connect(getNode(name: "pathNode_139")!, getNode(name: "pathNode_1")!)
        connect(getNode(name: "pathNode_139")!, getNode(name: "pathNode_131")!)
        connect(getNode(name: "pathNode_139")!, getNode(name: "pathNode_138")!)
        connect(getNode(name: "pathNode_139")!, getNode(name: "pathNode_53")!)
        
        connect(getNode(name: "pathNode_196")!, getNode(name: "pathNode_1")!)
        connect(getNode(name: "pathNode_196")!, getNode(name: "locationNode_37")!)
        connect(getNode(name: "pathNode_196")!, getNode(name: "pathNode_21")!)
        
        connect(getNode(name: "pathNode_21")!, getNode(name: "pathNode_22")!)
        
        connect(getNode(name: "pathNode_22")!, getNode(name: "pathNode_19")!)
        connect(getNode(name: "pathNode_22")!, getNode(name: "pathNode_23")!)
        
        connect(getNode(name: "pathNode_19")!, getNode(name: "pathNode_18")!)
        connect(getNode(name: "pathNode_19")!, getNode(name: "pathNode_23")!)
        
        connect(getNode(name: "pathNode_23")!, getNode(name: "pathNode")!)
        
        connect(getNode(name: "pathNode_18")!, getNode(name: "pathNode")!)
        connect(getNode(name: "pathNode_18")!, getNode(name: "pathNode_17")!)
        connect(getNode(name: "pathNode_18")!, getNode(name: "pathNode_26")!)
        
        connect(getNode(name: "pathNode_17")!, getNode(name: "pathNode_26")!)
        connect(getNode(name: "pathNode_17")!, getNode(name: "pathNode_62")!)
        
        connect(getNode(name: "pathNode_68")!, getNode(name: "pathNode_62")!)
        connect(getNode(name: "pathNode_68")!, getNode(name: "locationNode_54")!)
        connect(getNode(name: "pathNode_68")!, getNode(name: "pathNode_63")!)
        connect(getNode(name: "pathNode_68")!, getNode(name: "pathNode_66")!)
        connect(getNode(name: "pathNode_68")!, getNode(name: "pathNode_67")!)
        
        connect(getNode(name: "pathNode_62")!, getNode(name: "locationNode_54")!)
        
        connect(getNode(name: "pathNode_64")!, getNode(name: "pathNode_63")!)
        connect(getNode(name: "pathNode_64")!, getNode(name: "pathNode_10")!)
        connect(getNode(name: "pathNode_64")!, getNode(name: "pathNode_65")!)
        
        connect(getNode(name: "pathNode_66")!, getNode(name: "pathNode_63")!)
        connect(getNode(name: "pathNode_66")!, getNode(name: "pathNode_67")!)
        connect(getNode(name: "pathNode_66")!, getNode(name: "pathNode_12")!)
        
        connect(getNode(name: "pathNode_10")!, getNode(name: "pathNode_63")!)
        connect(getNode(name: "pathNode_10")!, getNode(name: "pathNode_9")!)
        connect(getNode(name: "pathNode_10")!, getNode(name: "pathNode_74")!)
        
        connect(getNode(name: "pathNode_65")!, getNode(name: "pathNode_7")!)
        connect(getNode(name: "pathNode_65")!, getNode(name: "locationNode_6")!)
        
        connect(getNode(name: "pathNode_9")!, getNode(name: "pathNode_7")!)
        connect(getNode(name: "pathNode_9")!, getNode(name: "pathNode_74")!)
        
        connect(getNode(name: "pathNode_74")!, getNode(name: "pathNode_71")!)
        connect(getNode(name: "pathNode_74")!, getNode(name: "pathNode_73")!)
        
        connect(getNode(name: "pathNode_73")!, getNode(name: "locationNode")!)
        connect(getNode(name: "pathNode_73")!, getNode(name: "pathNode_75")!)
        connect(getNode(name: "pathNode_73")!, getNode(name: "pathNode_70")!)
        connect(getNode(name: "pathNode_73")!, getNode(name: "pathNode_78")!)
        
        connect(getNode(name: "pathNode_75")!, getNode(name: "pathNode_72")!)
        connect(getNode(name: "pathNode_75")!, getNode(name: "pathNode_78")!)
        connect(getNode(name: "pathNode_75")!, getNode(name: "pathNode_76")!)
        
        connect(getNode(name: "pathNode_71")!, getNode(name: "pathNode_72")!)
        connect(getNode(name: "pathNode_71")!, getNode(name: "pathNode_70")!)
        
        connect(getNode(name: "pathNode_72")!, getNode(name: "pathNode_70")!)
        connect(getNode(name: "pathNode_72")!, getNode(name: "pathNode_76")!)
        
        connect(getNode(name: "pathNode_70")!, getNode(name: "pathNode_69")!)
        connect(getNode(name: "pathNode_70")!, getNode(name: "pathNode_90")!)
        connect(getNode(name: "pathNode_70")!, getNode(name: "pathNode_81")!)
        
        connect(getNode(name: "pathNode_12")!, getNode(name: "pathNode_69")!)
        connect(getNode(name: "pathNode_12")!, getNode(name: "pathNode_13")!)
        
        connect(getNode(name: "pathNode_69")!, getNode(name: "pathNode_13")!)
        connect(getNode(name: "pathNode_69")!, getNode(name: "pathNode_90")!)
        
        connect(getNode(name: "pathNode_67")!, getNode(name: "locationNode_5")!)
        connect(getNode(name: "pathNode_67")!, getNode(name: "pathNode_13")!)
        connect(getNode(name: "pathNode_67")!, getNode(name: "pathNode_63")!)
        connect(getNode(name: "pathNode_67")!, getNode(name: "pathNode_48")!)
        connect(getNode(name: "pathNode_67")!, getNode(name: "locationNode_3")!)
        
        connect(getNode(name: "pathNode_48")!, getNode(name: "locationNode_3")!)
        connect(getNode(name: "pathNode_48")!, getNode(name: "pathNode_50")!)
        connect(getNode(name: "pathNode_48")!, getNode(name: "locationNode_52")!)
        connect(getNode(name: "pathNode_48")!, getNode(name: "pathNode_47")!)
        connect(getNode(name: "pathNode_48")!, getNode(name: "pathNode_49")!)
        connect(getNode(name: "pathNode_48")!, getNode(name: "pathNode_14")!)
        connect(getNode(name: "pathNode_48")!, getNode(name: "pathNode_13")!)
        
//        connect(getNode(name: "pathNode_14")!, getNode(name: "pathNode_50")!)
        connect(getNode(name: "pathNode_14")!, getNode(name: "pathNode_15")!)
        connect(getNode(name: "pathNode_14")!, getNode(name: "pathNode_88")!)
        connect(getNode(name: "pathNode_14")!, getNode(name: "pathNode_13")!)
        
        connect(getNode(name: "pathNode_13")!, getNode(name: "pathNode_88")!)
        
        connect(getNode(name: "pathNode_90")!, getNode(name: "pathNode_89")!)
        connect(getNode(name: "pathNode_90")!, getNode(name: "pathNode_82")!)
        
        connect(getNode(name: "pathNode_78")!, getNode(name: "pathNode_77")!)
        connect(getNode(name: "pathNode_78")!, getNode(name: "pathNode_108")!)
        
        connect(getNode(name: "pathNode_76")!, getNode(name: "pathNode_80")!)
        connect(getNode(name: "pathNode_76")!, getNode(name: "pathNode_79")!)
        connect(getNode(name: "pathNode_76")!, getNode(name: "pathNode_106")!)
        
        connect(getNode(name: "pathNode_77")!, getNode(name: "pathNode_76")!)
        connect(getNode(name: "pathNode_77")!, getNode(name: "pathNode_107")!)
        
        connect(getNode(name: "pathNode_80")!, getNode(name: "pathNode_79")!)
        connect(getNode(name: "pathNode_80")!, getNode(name: "pathNode_81")!)
        
        connect(getNode(name: "pathNode_54")!, getNode(name: "locationNode_15")!)
        connect(getNode(name: "pathNode_54")!, getNode(name: "pathNode_5")!)
        
        connect(getNode(name: "pathNode_108")!, getNode(name: "pathNode_107")!)
        connect(getNode(name: "pathNode_108")!, getNode(name: "pathNode_109")!)
        connect(getNode(name: "pathNode_108")!, getNode(name: "pathNode_119")!)
        
        connect(getNode(name: "locationNode_56")!, getNode(name: "pathNode_119")!)
        
        connect(getNode(name: "pathNode_109")!, getNode(name: "pathNode_110")!)
        connect(getNode(name: "pathNode_109")!, getNode(name: "pathNode_113")!)
        
        connect(getNode(name: "pathNode_119")!, getNode(name: "pathNode_118")!)
        
        connect(getNode(name: "locationNode_9")!, getNode(name: "pathNode_118")!)
        
        connect(getNode(name: "pathNode_117")!, getNode(name: "pathNode_118")!)
        connect(getNode(name: "pathNode_117")!, getNode(name: "pathNode_116")!)
        connect(getNode(name: "pathNode_117")!, getNode(name: "locationNode_46")!)
        connect(getNode(name: "pathNode_117")!, getNode(name: "locationNode_44")!)
        connect(getNode(name: "pathNode_117")!, getNode(name: "pathNode_123")!)
        
        connect(getNode(name: "pathNode_116")!, getNode(name: "locationNode_47")!)
        connect(getNode(name: "pathNode_116")!, getNode(name: "pathNode_115")!)
        
        connect(getNode(name: "pathNode_114")!, getNode(name: "pathNode_115")!)
        connect(getNode(name: "pathNode_114")!, getNode(name: "locationNode_10")!)
        connect(getNode(name: "pathNode_114")!, getNode(name: "pathNode_113")!)
        
        connect(getNode(name: "pathNode_112")!, getNode(name: "pathNode_113")!)
        connect(getNode(name: "pathNode_112")!, getNode(name: "pathNode_111")!)
        
        connect(getNode(name: "pathNode_110")!, getNode(name: "pathNode_111")!)
        
        connect(getNode(name: "locationNode_35")!, getNode(name: "pathNode_111")!)
        connect(getNode(name: "locationNode_35")!, getNode(name: "pathNode_107")!)
        
        connect(getNode(name: "pathNode_107")!, getNode(name: "pathNode_106")!)
        
        connect(getNode(name: "pathNode_79")!, getNode(name: "pathNode_105")!)
        connect(getNode(name: "pathNode_79")!, getNode(name: "pathNode_104")!)
        
        connect(getNode(name: "pathNode_105")!, getNode(name: "locationNode_8")!)
        connect(getNode(name: "pathNode_105")!, getNode(name: "pathNode_106")!)
        connect(getNode(name: "pathNode_105")!, getNode(name: "pathNode_104")!)
        
        connect(getNode(name: "pathNode_106")!, getNode(name: "locationNode_8")!)
        
        connect(getNode(name: "pathNode_104")!, getNode(name: "pathNode_103")!)
        
        connect(getNode(name: "pathNode_123")!, getNode(name: "locationNode_11")!)
        connect(getNode(name: "pathNode_123")!, getNode(name: "locationNode_43")!)
        connect(getNode(name: "pathNode_123")!, getNode(name: "locationNode_44")!)
        
        connect(getNode(name: "locationNode_42")!, getNode(name: "pathNode_122")!)
        
        connect(getNode(name: "pathNode_131")!, getNode(name: "locationNode_13")!)
        connect(getNode(name: "pathNode_131")!, getNode(name: "pathNode_132")!)
        
        connect(getNode(name: "pathNode_138")!, getNode(name: "pathNode_132")!)
        connect(getNode(name: "pathNode_138")!, getNode(name: "pathNode_137")!)
        
        connect(getNode(name: "pathNode_133")!, getNode(name: "pathNode_132")!)
        connect(getNode(name: "pathNode_133")!, getNode(name: "pathNode_134")!)
        
        connect(getNode(name: "locationNode_36")!, getNode(name: "pathNode_137")!)
        connect(getNode(name: "locationNode_36")!, getNode(name: "pathNode_136")!)
        
        connect(getNode(name: "pathNode_135")!, getNode(name: "pathNode_134")!)
        connect(getNode(name: "pathNode_135")!, getNode(name: "pathNode_140")!)
        
        connect(getNode(name: "pathNode_136")!, getNode(name: "pathNode_134")!)
        connect(getNode(name: "pathNode_136")!, getNode(name: "pathNode_140")!)
        
        connect(getNode(name: "pathNode_134")!, getNode(name: "locationNode_38")!)
        
        connect(getNode(name: "pathNode_137")!, getNode(name: "pathNode_134")!)
        
        connect(getNode(name: "pathNode_140")!, getNode(name: "locationNode_16")!)
        connect(getNode(name: "pathNode_140")!, getNode(name: "pathNode_141")!)
        
        connect(getNode(name: "pathNode_141")!, getNode(name: "pathNode")!)
        connect(getNode(name: "pathNode_141")!, getNode(name: "pathNode_142")!)

        connect(getNode(name: "pathNode_24")!, getNode(name: "pathNode")!)
        connect(getNode(name: "pathNode_24")!, getNode(name: "pathNode_141")!)
        connect(getNode(name: "pathNode_24")!, getNode(name: "pathNode_25")!)
        connect(getNode(name: "pathNode_24")!, getNode(name: "pathNode_145")!)
        
        connect(getNode(name: "pathNode_143")!, getNode(name: "pathNode_142")!)
        connect(getNode(name: "pathNode_143")!, getNode(name: "pathNode_145")!)
        connect(getNode(name: "pathNode_143")!, getNode(name: "pathNode_144")!)
        
        connect(getNode(name: "pathNode_146")!, getNode(name: "pathNode_145")!)
        connect(getNode(name: "pathNode_146")!, getNode(name: "pathNode_28")!)
        connect(getNode(name: "pathNode_146")!, getNode(name: "pathNode_147")!)
        
        connect(getNode(name: "locationNode_17")!, getNode(name: "pathNode_142")!)
        
        connect(getNode(name: "pathNode_25")!, getNode(name: "pathNode_32")!)
        connect(getNode(name: "pathNode_25")!, getNode(name: "pathNode_26")!)
        
        connect(getNode(name: "pathNode_26")!, getNode(name: "locationNode_4")!)
        connect(getNode(name: "pathNode_26")!, getNode(name: "pathNode_27")!)
        
        connect(getNode(name: "locationNode_4")!, getNode(name: "pathNode_27")!)
        
        connect(getNode(name: "pathNode_27")!, getNode(name: "pathNode_32")!)
        connect(getNode(name: "pathNode_27")!, getNode(name: "pathNode_33")!)
        
        connect(getNode(name: "pathNode_28")!, getNode(name: "pathNode_32")!)
        connect(getNode(name: "pathNode_28")!, getNode(name: "pathNode_31")!)
        connect(getNode(name: "pathNode_28")!, getNode(name: "pathNode_29")!)
        
        connect(getNode(name: "pathNode_32")!, getNode(name: "pathNode_33")!)
        
        connect(getNode(name: "pathNode_29")!, getNode(name: "pathNode_146")!)
        connect(getNode(name: "pathNode_29")!, getNode(name: "pathNode_147")!)
        connect(getNode(name: "pathNode_29")!, getNode(name: "locationNode_18")!)
        connect(getNode(name: "pathNode_29")!, getNode(name: "pathNode_30")!)
        
        connect(getNode(name: "pathNode_30")!, getNode(name: "pathNode_28")!)
        
        connect(getNode(name: "locationNode_19")!, getNode(name: "pathNode_30")!)
        
        connect(getNode(name: "pathNode_36")!, getNode(name: "pathNode_35")!)
        connect(getNode(name: "pathNode_36")!, getNode(name: "pathNode_31")!)
        connect(getNode(name: "pathNode_36")!, getNode(name: "pathNode_167")!)
         
        connect(getNode(name: "pathNode_165")!, getNode(name: "pathNode_167")!)
        connect(getNode(name: "pathNode_165")!, getNode(name: "pathNode_166")!)
        connect(getNode(name: "pathNode_165")!, getNode(name: "pathNode_164")!)
        connect(getNode(name: "pathNode_165")!, getNode(name: "pathNode_41")!)
         
        connect(getNode(name: "pathNode_35")!, getNode(name: "pathNode_167")!)
        connect(getNode(name: "pathNode_35")!, getNode(name: "pathNode_166")!)
         
        connect(getNode(name: "pathNode_42")!, getNode(name: "pathNode_166")!)
        connect(getNode(name: "pathNode_42")!, getNode(name: "pathNode_41")!)
        connect(getNode(name: "pathNode_42")!, getNode(name: "pathNode_174")!)
        connect(getNode(name: "pathNode_42")!, getNode(name: "pathNode_43")!)
         
        connect(getNode(name: "pathNode_173_2")!, getNode(name: "pathNode_174")!)
        connect(getNode(name: "pathNode_173_2")!, getNode(name: "pathNode_172")!)
        connect(getNode(name: "pathNode_173_2")!, getNode(name: "pathNode_173")!)
         
        connect(getNode(name: "locationNode_45")!, getNode(name: "pathNode_174")!)
        connect(getNode(name: "locationNode_45")!, getNode(name: "pathNode_175")!)
         
        connect(getNode(name: "pathNode_176")!, getNode(name: "pathNode_175")!)
        connect(getNode(name: "pathNode_176")!, getNode(name: "pathNode_177")!)
        connect(getNode(name: "pathNode_176")!, getNode(name: "pathNode_181")!)
        connect(getNode(name: "pathNode_176")!, getNode(name: "pathNode_179")!)
        connect(getNode(name: "pathNode_176")!, getNode(name: "pathNode_178")!)
         
        connect(getNode(name: "pathNode_174")!, getNode(name: "pathNode_175")!)
        connect(getNode(name: "pathNode_174")!, getNode(name: "pathNode_181")!)
         
        connect(getNode(name: "pathNode_181")!, getNode(name: "pathNode_180")!)
         
        connect(getNode(name: "pathNode_179")!, getNode(name: "pathNode_180")!)
        connect(getNode(name: "pathNode_179")!, getNode(name: "pathNode_178")!)
         
        connect(getNode(name: "pathNode_180")!, getNode(name: "pathNode_30")!)
         
        connect(getNode(name: "pathNode_30")!, getNode(name: "pathNode_31")!)
         
        connect(getNode(name: "pathNode_167")!, getNode(name: "pathNode_164")!)
         
        connect(getNode(name: "pathNode_30")!, getNode(name: "pathNode_167")!)
         
        connect(getNode(name: "pathNode_178")!, getNode(name: "locationNode_20")!)
        connect(getNode(name: "pathNode_178")!, getNode(name: "pathNode_177")!)
         
        connect(getNode(name: "pathNode_175")!, getNode(name: "pathNode_181")!)
         
        connect(getNode(name: "pathNode_177")!, getNode(name: "locationNode_20")!)
        connect(getNode(name: "pathNode_177")!, getNode(name: "pathNode_175")!)
         
        connect(getNode(name: "pathNode_173")!, getNode(name: "locationNode_48")!)
        connect(getNode(name: "pathNode_173")!, getNode(name: "pathNode_195")!)
         
        connect(getNode(name: "pathNode_194")!, getNode(name: "pathNode_195")!)
        connect(getNode(name: "pathNode_194")!, getNode(name: "pathNode_172")!)
        connect(getNode(name: "pathNode_194")!, getNode(name: "locationNode_21")!)
         
        connect(getNode(name: "pathNode_193")!, getNode(name: "locationNode_21")!)
        connect(getNode(name: "pathNode_193")!, getNode(name: "pathNode_172")!)
         
        connect(getNode(name: "pathNode_192")!, getNode(name: "pathNode_193")!)
        connect(getNode(name: "pathNode_192")!, getNode(name: "pathNode_191")!)
         
        connect(getNode(name: "locationNode_21")!, getNode(name: "pathNode_172")!)
         
        connect(getNode(name: "pathNode_172")!, getNode(name: "locationNode_49")!)
         
        connect(getNode(name: "pathNode_195")!, getNode(name: "locationNode_48")!)
         
        connect(getNode(name: "pathNode_191")!, getNode(name: "pathNode_168")!)
         
        connect(getNode(name: "pathNode_169")!, getNode(name: "pathNode_168")!)
         
        connect(getNode(name: "pathNode_43")!, getNode(name: "pathNode_168")!)
        connect(getNode(name: "pathNode_43")!, getNode(name: "pathNode_39")!)
         
        connect(getNode(name: "pathNode_168")!, getNode(name: "pathNode_39")!)
         
        connect(getNode(name: "pathNode_39")!, getNode(name: "locationNode_50")!)
        connect(getNode(name: "pathNode_39")!, getNode(name: "pathNode_40")!)
        connect(getNode(name: "pathNode_39")!, getNode(name: "pathNode_44")!)
         
        connect(getNode(name: "pathNode_44")!, getNode(name: "locationNode_50")!)
        connect(getNode(name: "pathNode_44")!, getNode(name: "pathNode_37")!)
        connect(getNode(name: "pathNode_44")!, getNode(name: "pathNode_45")!)
         
        connect(getNode(name: "pathNode_41")!, getNode(name: "pathNode_40")!)
         
        connect(getNode(name: "pathNode_40")!, getNode(name: "pathNode_38")!)
        connect(getNode(name: "pathNode_40")!, getNode(name: "pathNode_37")!)
         
        connect(getNode(name: "pathNode_37")!, getNode(name: "pathNode_38")!)
         
        connect(getNode(name: "pathNode_38")!, getNode(name: "pathNode_34")!)
        connect(getNode(name: "pathNode_38")!, getNode(name: "pathNode_47")!)
         
        connect(getNode(name: "pathNode_164")!, getNode(name: "pathNode_34")!)
         
        connect(getNode(name: "pathNode_49")!, getNode(name: "pathNode_47")!)
        connect(getNode(name: "pathNode_49")!, getNode(name: "pathNode_34")!)
        connect(getNode(name: "pathNode_49")!, getNode(name: "pathNode_33")!)
         
        connect(getNode(name: "pathNode_33")!, getNode(name: "pathNode_34")!)
        
        connect(getNode(name: "pathNode_47")!, getNode(name: "pathNode_46")!)
          
        connect(getNode(name: "locationNode_22")!, getNode(name: "pathNode_46")!)
          
        connect(getNode(name: "pathNode_45")!, getNode(name: "pathNode_46")!)
        connect(getNode(name: "pathNode_45")!, getNode(name: "locationNode_53")!)
        connect(getNode(name: "pathNode_45")!, getNode(name: "pathNode_159")!)
        connect(getNode(name: "pathNode_45")!, getNode(name: "pathNode_158")!)
        connect(getNode(name: "pathNode_45")!, getNode(name: "pathNode_170")!)
          
        connect(getNode(name: "pathNode_159")!, getNode(name: "pathNode_170")!)
        connect(getNode(name: "pathNode_159")!, getNode(name: "locationNode_53")!)
        connect(getNode(name: "pathNode_159")!, getNode(name: "pathNode_158")!)
        connect(getNode(name: "pathNode_159")!, getNode(name: "pathNode_160")!)
          
        connect(getNode(name: "pathNode_158")!, getNode(name: "pathNode_45")!)
        connect(getNode(name: "pathNode_158")!, getNode(name: "pathNode_44")!)
          
        connect(getNode(name: "pathNode_160")!, getNode(name: "locationNode_27")!)
        connect(getNode(name: "pathNode_160")!, getNode(name: "pathNode_171")!)
        connect(getNode(name: "pathNode_160")!, getNode(name: "pathNode_157")!)
          
        connect(getNode(name: "pathNode_157")!, getNode(name: "pathNode_158")!)
        connect(getNode(name: "pathNode_157")!, getNode(name: "pathNode_156")!)
          
        connect(getNode(name: "pathNode_156")!, getNode(name: "pathNode_16")!)
        connect(getNode(name: "pathNode_156")!, getNode(name: "pathNode_155")!)
          
        connect(getNode(name: "pathNode_16")!, getNode(name: "locationNode_23")!)
        connect(getNode(name: "pathNode_16")!, getNode(name: "locationNode_24")!)
        connect(getNode(name: "pathNode_16")!, getNode(name: "pathNode_51")!)
          
        connect(getNode(name: "pathNode_52")!, getNode(name: "pathNode_51")!)
        connect(getNode(name: "pathNode_52")!, getNode(name: "pathNode_50")!)
          
        connect(getNode(name: "pathNode_51")!, getNode(name: "pathNode_15")!)
          
        connect(getNode(name: "pathNode_155")!, getNode(name: "locationNode_29")!)
        connect(getNode(name: "pathNode_155")!, getNode(name: "pathNode_154")!)
          
        connect(getNode(name: "pathNode_153")!, getNode(name: "locationNode_26")!)
        connect(getNode(name: "pathNode_153")!, getNode(name: "pathNode_154")!)
        connect(getNode(name: "pathNode_153")!, getNode(name: "pathNode_152")!)
          
        connect(getNode(name: "pathNode_154")!, getNode(name: "pathNode_161")!)
        connect(getNode(name: "pathNode_154")!, getNode(name: "locationNode_28")!)
          
        connect(getNode(name: "pathNode_161")!, getNode(name: "pathNode_162")!)
        connect(getNode(name: "pathNode_161")!, getNode(name: "locationNode_28")!)
          
        connect(getNode(name: "pathNode_152")!, getNode(name: "pathNode_162")!)
        connect(getNode(name: "pathNode_152")!, getNode(name: "pathNode_151")!)
          
        connect(getNode(name: "pathNode_151")!, getNode(name: "locationNode_25")!)
        connect(getNode(name: "pathNode_151")!, getNode(name: "pathNode_150")!)
          
        connect(getNode(name: "pathNode_150")!, getNode(name: "locationNode_30")!)
        connect(getNode(name: "pathNode_150")!, getNode(name: "pathNode_149")!)
          
        connect(getNode(name: "pathNode_149")!, getNode(name: "pathNode_91")!)
        connect(getNode(name: "pathNode_149")!, getNode(name: "pathNode_148")!)
          
        connect(getNode(name: "pathNode_148")!, getNode(name: "locationNode_31")!)
        connect(getNode(name: "pathNode_148")!, getNode(name: "pathNode_94")!)
          
        connect(getNode(name: "pathNode_94")!, getNode(name: "locationNode_31")!)
        connect(getNode(name: "pathNode_94")!, getNode(name: "pathNode_95")!)
        connect(getNode(name: "pathNode_94")!, getNode(name: "pathNode_93")!)
          
        connect(getNode(name: "pathNode_93")!, getNode(name: "pathNode_92")!)
        connect(getNode(name: "pathNode_93")!, getNode(name: "pathNode_95")!)
          
        connect(getNode(name: "pathNode_95")!, getNode(name: "pathNode_96")!)
          
        connect(getNode(name: "pathNode_96")!, getNode(name: "pathNode_101")!)
        connect(getNode(name: "pathNode_96")!, getNode(name: "pathNode_97")!)
          
        connect(getNode(name: "pathNode_98")!, getNode(name: "pathNode_100")!)
        connect(getNode(name: "pathNode_98")!, getNode(name: "pathNode_101")!)
          
        connect(getNode(name: "pathNode_102")!, getNode(name: "pathNode_100")!)
        connect(getNode(name: "pathNode_102")!, getNode(name: "locationNode_34")!)
        connect(getNode(name: "pathNode_102")!, getNode(name: "pathNode_103")!)
          
        connect(getNode(name: "pathNode_99")!, getNode(name: "pathNode_103")!)
        connect(getNode(name: "pathNode_99")!, getNode(name: "pathNode_97")!)
        connect(getNode(name: "pathNode_99")!, getNode(name: "pathNode_100")!)
          
        connect(getNode(name: "pathNode_97")!, getNode(name: "locationNode_33")!)
        connect(getNode(name: "pathNode_97")!, getNode(name: "pathNode_98")!)
          
        connect(getNode(name: "pathNode_87")!, getNode(name: "pathNode_15")!)
        connect(getNode(name: "pathNode_87")!, getNode(name: "pathNode_88")!)
        connect(getNode(name: "pathNode_87")!, getNode(name: "pathNode_163")!)
          
        connect(getNode(name: "pathNode_163")!, getNode(name: "pathNode_89")!)
        connect(getNode(name: "pathNode_163")!, getNode(name: "pathNode_86")!)
        connect(getNode(name: "pathNode_163")!, getNode(name: "locationNode_1")!)
          
        connect(getNode(name: "pathNode_86")!, getNode(name: "pathNode_85")!)
        connect(getNode(name: "pathNode_86")!, getNode(name: "pathNode_83")!)
        connect(getNode(name: "pathNode_86")!, getNode(name: "pathNode_82")!)
          
        connect(getNode(name: "pathNode_83")!, getNode(name: "pathNode_89")!)
        connect(getNode(name: "pathNode_83")!, getNode(name: "locationNode_2")!)
        connect(getNode(name: "pathNode_83")!, getNode(name: "pathNode_84")!)
        connect(getNode(name: "pathNode_83")!, getNode(name: "pathNode_82")!)
          
        connect(getNode(name: "pathNode_82")!, getNode(name: "locationNode_2")!)
        connect(getNode(name: "pathNode_82")!, getNode(name: "pathNode_81")!)
          
        connect(getNode(name: "pathNode_81")!, getNode(name: "locationNode_2")!)
          
        connect(getNode(name: "pathNode_84")!, getNode(name: "locationNode_2")!)
          
        connect(getNode(name: "pathNode_91")!, getNode(name: "pathNode_92")!)
        connect(getNode(name: "pathNode_91")!, getNode(name: "pathNode_84")!)
          
        connect(getNode(name: "pathNode_92")!, getNode(name: "pathNode_84")!)
          
        connect(getNode(name: "locationNode_51")!, getNode(name: "pathNode_91")!)
          
        connect(getNode(name: "pathNode_85")!, getNode(name: "pathNode_84")!)
          
        connect(getNode(name: "locationNode_32")!, getNode(name: "pathNode_101")!)
          
        connect(getNode(name: "pathNode_95")!, getNode(name: "locationNode_32")!)
        
        connect(getNode(name: "pathNode_88")!, getNode(name: "pathNode_89")!)
        
    }
}


func appendToScene(scene: SCNScene, webGraph: WebGraph) {
    for node in webGraph.nodes {
        let sphere = SCNSphere(radius: 0.1)
        sphere.segmentCount = 16
        sphere.materials.first?.lightingModel = .constant
        
        #if os(iOS)
        sphere.materials.first?.diffuse.contents = UIColor.red
        #elseif os(macOS)
        sphere.materials.first?.diffuse.contents = NSColor.red
        #endif
        
        let graphNode = SCNNode(geometry: sphere)
        #if os(macOS)
        graphNode.position = SCNVector3(x: CGFloat(node.xpos), y: 0, z: CGFloat(node.zpos))
        #elseif os(iOS)
        graphNode.position = SCNVector3(x: Float(node.xpos), y: 0, z: Float(node.zpos))
        #endif
        scene.rootNode.addChildNode(graphNode)
    }
}


