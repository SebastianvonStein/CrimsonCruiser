//
//  SceneKitView.swift
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
 
 ▄▀▀ ▄▀▀ ██▀ █▄ █ ██▀   █▄▀ █ ▀█▀
 ▄██ ▀▄▄ █▄▄ █ ▀█ █▄▄   █ █ █  █
 */

import SwiftUI
import SceneKit

/// This view displays a SceneKit `SCNScene` - in this case the AnnotatedModel.scn and manages interactions with nodes and driving.
/// > Gesture Recongition is supported but currently used in DebugNodeGraph for establishing node connections. Not utilized in "active" build.
/// - Parameters:
///   - scene: A binding to the `SCNScene` to be displayed in the view.
///   - selectedNode: A binding to the name of the currently selected node (optional).
struct SceneKitView: PlatformAgnosticViewRepresentable {
    
    @Binding var scene: SCNScene
    @Binding var sceneView: SCNView
    //@Binding var selectedNode: String?
    @Binding var bindingData: CarData
    @Binding var nodeBindingData: NodeData
    
    var nodeTree: WebGraph = WebGraph()
    
    @Binding var distance: CGFloat
    
    func makePlatformView(context: Context) -> SCNView {
        let scnView = sceneView
        // Scene Init Params:
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor = .clear
        scnView.scene?.physicsWorld.gravity = SCNVector3(0, -19.8, 0)
        
        // scnView.debugOptions = [.showCameras, .showWireframe, .showLightInfluences]
        
        /*
        // MARK: Gesture Recognizer
        #if os(iOS)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        #elseif os(macOS)
        let clickGesture = NSClickGestureRecognizer(target: context.coordinator, action:
            #selector(context.coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(clickGesture)
        #endif
        */
        
        return scnView
    }
    
    /*
    /// Creates a coordinator to manage gestures and node selection. used only for DEBUG!
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedNode: $selectedNode)
    }
    */
    
    
    /// Updates the platform-specific view when data changes or is updated.
    func updatePlatformView(_ view: SCNView, context: Context) {
        view.scene = scene
        carController(view: view, bindingData: bindingData)
                
        if let car = scene.rootNode.childNode(withName: "locatorNode", recursively: true) {

            //print(car.presentation.worldPosition)
            
            if let destNode = nodeTree.getNode(name: "locationNode".appending(nodeBindingData.selectedDestinationNode)) {
                
                let distanceToDestination = CarDistance(carPos: car.presentation.worldPosition, destNode: destNode)
                
                // THIS UPDATED DISTNACE VARIABLE ISN'T BEING PASSED BACK TO THE PARRENT VIEW THROUGH THE BINDING...
                //distance = distanceToDestination
                
                DispatchQueue.main.async {
                    distance = distanceToDestination
                }
                
                if distanceToDestination < 18 {
                    print("ARRIVED")
                    
                }
                
            } else { print("no dest node found") }
        } else { print("no car currenlty") }
    }
    
    /*
    /// A class to manage gesture recognition and node selection for the SceneKit view.
    class Coordinator: NSObject {
        @Binding var selectedNode: String?
        
        init(selectedNode: Binding<String?>) {
            self._selectedNode = selectedNode
        }
        
        #if os(iOS)
        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
          if let nodeName = GestureHandler.handleTap(gestureRecognize) {
              selectedNode = nodeName
          } else { selectedNode = nil } }
        #elseif os(macOS)
        @objc func handleTap(_ gestureRecognize: NSClickGestureRecognizer) {
          if let nodeName = GestureHandler.handleTap(gestureRecognize) {
              selectedNode = nodeName
          } else { selectedNode = nil } }
        #endif
    }
    */
}


func addCar(scene: SCNScene, bindingData: CarData, pos: SCNVector3?) {
    let car = createPhysicsVehicle(scene: scene, bindingData: bindingData)
    //car.name = "car"
    scene.rootNode.addChildNode(car)
    
    if let p = pos {
        scene.rootNode.childNode(withName: "CHASSIS", recursively: true)!.position = SCNVector3(p.x, 3, p.z)
    } else {
        print("No car spawn position provided...")
    }
    
}


