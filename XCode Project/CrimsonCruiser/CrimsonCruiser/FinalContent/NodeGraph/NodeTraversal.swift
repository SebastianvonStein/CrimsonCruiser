//
//  NodeTraversal.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 11/22/24.
//

/*
 ▄▀▀ █▀▄ █ █▄ ▄█ ▄▀▀ ▄▀▄ █▄ █
 ▀▄▄ █▀▄ █ █ ▀ █ ▄██ ▀▄▀ █ ▀█
 
 ▄▀▀ █▀▄ █ █ █ ▄▀▀ ██▀ █▀▄
 ▀▄▄ █▀▄ ▀▄█ █ ▄██ █▄▄ █▀▄
 
 - - - - - - - - - - - - - - - -
 
 █▀▄ ▄▀▄ ▀█▀ █▄█ █▀ █ █▄ █ █▀▄ ██▀ █▀▄
 █▀  █▀█  █  █ █ █▀ █ █ ▀█ █▄▀ █▄▄ █▀▄
 */

import Foundation
import SceneKit

/// This function consolidates a variety of functions needed for pathfinding.
///
/// It checks the existence of both the departure and destination nodes,
/// calculates the shortest path between them using Dijkstra's algorithm, removes any
/// existing path lines in the scene, draws the new path, and centers the camera along
/// the computed path.
///
/// - Parameters:
///   - scene: The `SCNScene` where the path visualization and camera movement will occur.
///   - destinationNode: The name of the destination node as a `String`.
///   - departureNode: The name of the departure node as a `String`.
///   - nodeTree: The `WebGraph` representing the graph of nodes and connections.
///   - canDrive: An `inout` boolean flag to determine whether driving is allowed.
///     This flag is set to `false` after the path is calculated.
func consolidatedPathCalculation(scene: SCNScene, destinationNode: String, departureNode: String, nodeTree: WebGraph, disDrive: inout Bool) {
    // Check to make sure Destination Node exists and can be found!
    if let desNode = nodeTree.getNode(name: "locationNode".appending(destinationNode))
    {
        // Check to make sure Departure Node Exists and can be found!
        if let depNode = nodeTree.getNode(name: "locationNode".appending(departureNode)) {
            
            // Remove existing lines of old path
            removeAllLines(from: scene)
            
            // MARK: - Perform Dijkstras Algorithm
            let path: [WebNode] = nodeTree.findPath(start: depNode, end: desNode)
            
            // Check Path...
            if path.isEmpty
            { print("Path not found") }
            else
            { print("Path found!") }
        
            // Draw lines for path
            drawPath(pathNodes: path, scene: scene, lineWidth: 8)
            
            // Moves camera to center of path
            moveCamera(depNode: depNode, desNode: desNode, scene: scene)
            
            // Used to tell the application that a path exists and the driving can begin!
            disDrive = false
            
        } else {
            print("Could not create destination Node")
            disDrive = true
        }
        
    } else {
        print("Could not create departure Node")
        disDrive = true
    }
    
}
