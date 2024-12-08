//
//  DebugNodeGraph.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 11/16/24.
//

import SwiftUI
import SceneKit

/*
 
 ░▒█▀▀▄░▒█▀▀▀░▒█▀▀▄░▒█░▒█░▒█▀▀█
 ░▒█░▒█░▒█▀▀▀░▒█▀▀▄░▒█░▒█░▒█░▄▄
 ░▒█▄▄█░▒█▄▄▄░▒█▄▄█░░▀▄▄▀░▒█▄▄▀

 This view has its conents disabled currenlty
 It was used to establish all the node connections and test features...
 Reactivating this code will likley cause issues and not work...
 */



enum mode: String, CaseIterable {
    case selecting = "Selecting"
    case connecting = "Connecting"
}

struct DebugNodeGraph: View {
    
    @State var scene = SCNScene(named: "AnnotatedModel.scn")!
    @StateObject var nodeTree: WebGraph = WebGraph()
    
    @State var selectedNodeFromSceneKit: String?
    @State var selectedNode: WebNode?
    
    @State var selectedMode: mode = .selecting
    
    @State var loadedPaths: Bool = false
    @State var loadedTrees: Bool = false
    @State var loadedLocations: Bool = false
    
    @Environment(\.modelContext) var context
    
    var body: some View {
        VStack {
            ZStack() {
                /*
                SceneKitView(scene: $scene, selectedNode: $selectedNodeFromSceneKit)
                
                HStack(spacing: 0) {
                    
                    VStack() {
                        // MARK: Top Bar
                        HStack() {
                            Text("Crimson Cruiser")
                                .bold()
                                .padding(.leading, 6)
                           
                            Spacer()
                            
                            Button("Locations") {
                                navigateSceneTreeToFindNodes(scene: scene, name: "locationNode", color: .blue)
                            }.debugButtonStyle()
                            Button("Pathways") {
                                navigateSceneTreeToFindNodes(scene: scene, name: "pathNode", color: .red)
                            }.debugButtonStyle()
                            Button("Trees") {
                                navigateSceneTreeToFindNodes(scene: scene, name: "treeNode", color: .green)
                            }.debugButtonStyle()
                            
                            Divider()
                                .frame(height: 30)
                            
                            Button("Load Web-Graph") {
                                navigateSceneTreeToFindNodes(scene: scene, name: "treeNode", color: .green)
                            }.debugButtonStyle()
                            
                            Divider()
                                .frame(height: 30)
                            
                            Button("PA") {
                                printNodeNames(node: scene.rootNode)
                            }.debugButtonStyle()
                        }
                        .debugBGStyle()
    
                        Spacer()
                        
                        // MARK: Bottom Bar
                        HStack() {
                            VStack(alignment: .leading) {

                                HStack() {

                                    
                                    HStack() {
                                        Image(systemName: "cursorarrow.click")
                                            .font(.system(size: 13, weight: .bold, design: .default))
                                        Text("Select")
                                    }
                                    .debugButtonStyle()
                                    .padding(4)
                                    .background(.orange.opacity(selectedMode == .selecting ? 1 : 0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture {
                                        selectedMode = .selecting
                                    }
                                    
                                    HStack() {
                                        Image(systemName: "point.3.connected.trianglepath.dotted")
                                            .font(.system(size: 13, weight: .bold, design: .default))
                                        Text("Connect")
                                    }
                                    .debugButtonStyle()
                                    .padding(4)
                                    .background(.green.opacity(selectedMode == .connecting ? 1 : 0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture {
                                        selectedMode = .connecting
                                    }
                                    
                                    Button("LINK") {
                                        if selectedMode == .connecting {
                                            //recolorNode(name: nodeTree.selectedNodeName, scene: scene, backToOriginal: true)
                                            
                                            nodeTree.getNode(name: selectedNodeFromSceneKit!)?.setupdone = true
                                            
                                            //setLinkedColor(name: nodeTree.selectedNodeName, scene: scene)
                                            
                                            nodeTree.connectWithArray()
                                            selectedMode = .selecting
                                        } else {
                                           print("--- FAILED TO LINK ---")
                                        }
                                        
                                    }.debugButtonStyle()
                                    
                                    Button("DRAW LINKS") {
                                        drawConnections(in: nodeTree, scene: scene)
                                    }
                                        
                                    
                                }
                                .animation(.snappy, value: selectedMode)
                                
                                
                                
                            }
                        }
                        .debugBGStyle()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        HStack() {
                            Text("Node Manager")
                                .bold()
                            Spacer()
                        }
                        
                        HStack() {
                            Text("1stNode: \(nodeTree.selectedNodeName)")
                            Spacer()
                        }
                            
                        HStack() {
                            Text("2ndNode: \(nodeTree.secondSelectedNodeName)")
                            Spacer()
                        }
                        
                        HStack() {
                            Text("WG Nodes")
                            Spacer()
                            Button("Load"){
                                
                                navigateSceneTreeToCreateWebGraphNodes(scene: scene, webGraph: nodeTree, nodeType: .locations)
                                navigateSceneTreeToCreateWebGraphNodes(scene: scene, webGraph: nodeTree, nodeType: .pathways)
                                
                            }.debugButtonStyle(tall: false)
                        }
                        
                        ScrollView() {
                            VStack(alignment: .leading){
                                ForEach(nodeTree.nodes) { node in
                                    HStack() {
                                        Text(node.name)
                                        Spacer()
                                        Text(nodeTree.getConnections(for: node).count.description)
                                    }
                                    .background(.green.opacity( node.setupdone ? 0.4 : 0))
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Divider()
                        
                        HStack() {
                            Button("Store") {
                                nodeTree.saveToPersistentStore(context: context)
                            }.debugButtonStyle(tall: false)
                            
                            Button("Retrieve") {
                                nodeTree.loadFromPersistentStore(context: context)
                            }.debugButtonStyle(tall: false)
                            
                            Button("Preload") {
                                nodeTree.preload()
                            }.debugButtonStyle(tall: false)
                        }

                    }
                    .frame(width: 200)
                    .debugBGStyle()
                    .padding(.leading, -16)
                    
                }
                 */
            }
        /*
            .onChange(of: selectedNodeFromSceneKit ?? "") { new in
                if selectedMode == .selecting {
                    
                    if (new.contains("locationNode") || new.contains("pathNode")) {
                        //print("Selected \(new)")
                        
                        //recolorNode(name: nodeTree.selectedNodeName, scene: scene, backToOriginal: true)
                        
                        nodeTree.selectedNodeName = new
                        
                        let centralNode = nodeTree.getNode(name: new)
                        
                        //recolorNode(name: new, scene: scene)
                        
                        removeAllLines(from: scene)
                        
                        for connection in nodeTree.getConnections(for: nodeTree.getNode(name: new)!) {
                            //print(connection.name)
                            
                            addLineBetween(SCNVector3(connection.xpos, 0.5, connection.zpos), and: SCNVector3(centralNode?.xpos ?? 0, 0.5, centralNode?.zpos ?? 0), to: scene)
                            
                        }
                    }
                } else {
                    if new.contains(nodeTree.selectedNodeName) {
                        print("Tried selecting already selected node to connect...")
                    } else {
                        if (new.contains("locationNode") || new.contains("pathNode")) {
                            //print("Selected \(new)")
                            nodeTree.secondSelectedNodeName.append(new)
                            
                            let centralNode = nodeTree.getNode(name: nodeTree.selectedNodeName)
                            
                            let nn = nodeTree.getNode(name: new)
                            
                            addLineBetween(SCNVector3(centralNode!.xpos, 0.5, centralNode!.zpos), and: SCNVector3(nn!.xpos, 0.5, nn!.zpos), to: scene)
                            //addLineBetween(SCNVector3(new.xpos, 0.5, new.zpos), and: SCNVector3(nodeTree.getNode(name: nodeTree.selectedNodeName).xpos ?? 0, 0.5, nodeTree.getNode(name: nodeTree.selectedNodeName).zpos ?? 0), to: scene)
                        }
                    }
                }
            }
       */
            
        }
        .background(Color(red: 233/255, green: 235/255, blue: 226/255))
        
    }
    
    // Function to add a line between connected nodes
    func drawConnections(in webGraph: WebGraph, scene: SCNScene) {
        for (nodeID, connectedNodeIDs) in webGraph.connections {
            guard let centralNode = webGraph.nodes.first(where: { $0.id == nodeID }) else { continue }
            let startVector = SCNVector3(centralNode.xpos, 0.5, centralNode.zpos)
            
            for connectedNodeID in connectedNodeIDs {
                guard let connectedNode = webGraph.nodes.first(where: { $0.id == connectedNodeID }) else { continue }
                let endVector = SCNVector3(connectedNode.xpos, 0.5, connectedNode.zpos)
                
                // Add a line between the two nodes
                addLineBetween(startVector, and: endVector, to: scene)
            }
        }
    }
    
}


#Preview {
    DebugNodeGraph()
        .frame(width: 1000, height: 700)
}
