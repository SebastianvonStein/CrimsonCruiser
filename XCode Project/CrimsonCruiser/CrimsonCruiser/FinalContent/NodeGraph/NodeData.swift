//
//  NodeData.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 12/3/24.
//

import Foundation


struct NodeData {
    var selectedNodeFromSceneKit: String?
    var selectedDepartureName: String = "none selected"
    var selectedDepartureNode: String = "none"
    var selectedDestinationName: String = "none selected"
    var selectedDestinationNode: String = "none"
    var completedDrive: Bool = false
}
