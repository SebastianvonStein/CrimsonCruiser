//
//  ContentView.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 11/16/24.
//

/*
 ▄▀▀ █▀▄ █ █▄ ▄█ ▄▀▀ ▄▀▄ █▄ █
 ▀▄▄ █▀▄ █ █ ▀ █ ▄██ ▀▄▀ █ ▀█
 
 ▄▀▀ █▀▄ █ █ █ ▄▀▀ ██▀ █▀▄
 ▀▄▄ █▀▄ ▀▄█ █ ▄██ █▄▄ █▀▄
 */

import SwiftUI
import SceneKit

// MARK: Main App View
struct ContentView: View {
    
    // 3D Scene object loaded from stored SceneKit Model.
    @State var sceneView = SCNView()
    @State var scene = SCNScene(named: "AnnotatedModel.scn")!
    
    // Object that contains all nodes, relationships & relevant functions
    @StateObject var nodeTree: WebGraph = WebGraph()
  
    // Used for SwiftUI State animations
    @State var hoveringMain: Bool = false
    @State var disableDrive: Bool = true
    
    @State var distance: CGFloat = 0
  
    // Binding Data for the destination & departure nodes
    @State var nodeBindingData: NodeData = NodeData()
    // Binding Data for the vehcileState&Init - Partial inout
    @State var carBindingData: CarData = CarData(steeringAngle: 0, speed: 0, braking: false, accelerating: false, reversing: false, mass: 65, suspensionStiffness: 60, suspensionHeight: 0.4, friction: 0.54)
    
    @State var startedDriving: Bool = false
    
    @State var showFinishMessage: Bool = false
    
    // Key Manager & Timer for Driving on MacOSX
    // WASD&R
    @State var pressedKeys: [Bool] = [false, false, false, false, false]
    private let timer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()
    
    @State var startedDrivingTime: Double = Date().timeIntervalSince1970
    @State var endedDrivingTime: Double = Date().timeIntervalSince1970
    
    var body: some View {
        ZStack {
            
            // 3D Viewer
            SceneKitView(scene: $scene, sceneView: $sceneView, bindingData: $carBindingData, nodeBindingData: $nodeBindingData, nodeTree: nodeTree, distance: $distance)
                .ignoresSafeArea()
                .onKeyPress(phases: .all) { press in
                    handlePress(press: press, pressedKeys: &pressedKeys, pos: departurePos(nodeBindingData: nodeBindingData, nodeTree: nodeTree), scene: scene, sceneView: sceneView, startedDriving: &startedDriving)
                }
                .onReceive(timer) { _ in
                    handleDrivingStateFromKeys(press: pressedKeys, carBindingData: &carBindingData)
                }

            
            
            KeyViewCollection(pressedKeys: $pressedKeys, startedDriving: $startedDriving, distance: $distance)
            
            
            ZStack() {
                VStack(alignment: .leading) {
                    Text("Congratulations!")
                        .bold()
                        .padding(.vertical, 4)
                    
                    Text("You made it from \(nodeBindingData.selectedDepartureName) to \(nodeBindingData.selectedDestinationName) in:")
                    
                    Text(" \(String(format: "%.1f", (endedDrivingTime - startedDrivingTime) ) )  Seconds!")
                        .bold()
                        .padding(.vertical, 4)
                }
            }
            .frame(width: 300, height: 150)
            .padding(7)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .padding(8)
            .opacity(showFinishMessage ? 1 : 0)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            
            
            VStack() {
                Spacer()
                HStack() {
                    LocationList(selectedNode: $nodeBindingData.selectedDepartureNode, selectedLocation: $nodeBindingData.selectedDepartureName, descirption: "Departure:").padding(.horizontal, 16).frame(width: 260)
                    VStack() {
                        Spacer()
                        mainButton() {
                            startedDrivingTime = Date().timeIntervalSince1970
                            addCarConsolidated(startedDriving: &startedDriving, scene: scene, sceneView: sceneView, carBindingData: carBindingData, disableDrive: &disableDrive, nodeBindingData: nodeBindingData, nodeTree: nodeTree)
                        }
                        .disabled(disableDrive)
                    }
                    LocationList(selectedNode: $nodeBindingData.selectedDestinationNode, selectedLocation: $nodeBindingData.selectedDestinationName, descirption: "Destination:").padding(.horizontal, 16).frame(width: 260)
                }
                .padding(.bottom)
                .allowsHitTesting(!startedDriving)
                .opacity(startedDriving == false ? 1 : 0)
            }
        }
        #if os(iOS)
        .ignoresSafeArea()
        .statusBarHidden()
        #endif
        .background(Color(red: 233/255, green: 235/255, blue: 226/255))
        .onAppear() {
            // Initializes nodes and connections
            navigateSceneTreeToCreateWebGraphNodes(scene: scene, webGraph: nodeTree, nodeType: .locations)
            navigateSceneTreeToCreateWebGraphNodes(scene: scene, webGraph: nodeTree, nodeType: .pathways)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                nodeTree.preload()
            })
            
        }
        .onChange(of: nodeBindingData.selectedDestinationName, {
            consolidatedPathCalculation(scene: scene, destinationNode: nodeBindingData.selectedDestinationNode, departureNode: nodeBindingData.selectedDepartureNode, nodeTree: nodeTree, disDrive: &disableDrive)
        })
        .onChange(of: nodeBindingData.selectedDepartureName, {
            consolidatedPathCalculation(scene: scene, destinationNode: nodeBindingData.selectedDestinationNode, departureNode: nodeBindingData.selectedDepartureNode, nodeTree: nodeTree, disDrive: &disableDrive)
        })
        .onChange(of: distance) {
            if distance < 18 {
                removeCarConsolidated(scene: scene, sceneView: sceneView)
                startedDriving = false
                endedDrivingTime = Date().timeIntervalSince1970
                showFinishMessage = true
            }
        }
        .onChange(of: showFinishMessage) {
            if showFinishMessage == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    showFinishMessage = false
                })
            }
        }
        .animation(.snappy, value: startedDriving)
        .animation(.snappy, value: showFinishMessage)
        
        
    }
}

/*
#Preview {
    ContentView()
    #if os(macOS)
        .frame(width: 900, height: 500)
    #endif
}
*/

