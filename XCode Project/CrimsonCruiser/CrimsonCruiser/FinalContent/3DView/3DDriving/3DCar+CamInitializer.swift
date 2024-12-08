//
//  3DCarInitializer.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 12/3/24.
//

import Foundation
import SceneKit


func createPhysicsVehicle(scene: SCNScene, bindingData: CarData) -> (SCNNode) {
    
    let cpY: CGFloat = 0.2
    let wRadius: CGFloat = 1.55
    
    let carScene = SCNScene(named: "P8.scn")
    
    if let chassisNode = carScene!.rootNode.childNode(withName: "CHASSIS", recursively: false) {
        
        print("found chassis")
        
        let wheelNodeFL = chassisNode.childNode(withName: "WFL", recursively: true)
        let wheelNodeFR = chassisNode.childNode(withName: "WFR", recursively: true)
        let wheelNodeBL = chassisNode.childNode(withName: "WBL", recursively: true)
        let wheelNodeBR = chassisNode.childNode(withName: "WBR", recursively: true)
        
        let physicsBody = SCNPhysicsBody.dynamic()
        physicsBody.allowsResting = false
        physicsBody.mass = bindingData.mass
        physicsBody.rollingFriction = 0.45
        physicsBody.angularDamping = 0.45
        chassisNode.physicsBody = physicsBody
        
        let wheelFL = SCNPhysicsVehicleWheel(node: wheelNodeFL!)
        let wheelBL = SCNPhysicsVehicleWheel(node: wheelNodeBL!)
        let wheelFR = SCNPhysicsVehicleWheel(node: wheelNodeFR!)
        let wheelBR = SCNPhysicsVehicleWheel(node: wheelNodeBR!)
        
        wheelFL.radius = wRadius
        wheelFR.radius = wRadius
        wheelBL.radius = wRadius
        wheelBR.radius = wRadius
        
        
        wheelFL.connectionPosition = SCNVector3(x: -3.3, y: cpY, z: 6.5)
        wheelFR.connectionPosition = SCNVector3(x: 3.3, y: cpY, z: 6.5)
        wheelBL.connectionPosition = SCNVector3(x: -3.3, y: cpY, z: -6.5)
        wheelBR.connectionPosition = SCNVector3(x: 3.3, y: cpY, z: -6.5)
        
        
        // Set suspension properties
        wheelFL.suspensionStiffness = bindingData.suspensionStiffness
        wheelFL.suspensionRestLength = bindingData.suspensionHeight
        wheelFL.frictionSlip = 0.75
        
        wheelFR.suspensionStiffness = bindingData.suspensionStiffness
        wheelFR.suspensionRestLength = bindingData.suspensionHeight
        wheelFR.frictionSlip = 0.75
        
        wheelBL.suspensionStiffness = bindingData.suspensionStiffness
        wheelBL.suspensionRestLength = bindingData.suspensionHeight
        wheelBL.frictionSlip = 0.75
        
        wheelBR.suspensionStiffness = bindingData.suspensionStiffness
        wheelBR.suspensionRestLength = bindingData.suspensionHeight
        wheelBR.frictionSlip = 0.75
        
        // Create an SCNPhysicsVehicle with the chassis and wheels
        let vehicle = SCNPhysicsVehicle(chassisBody: chassisNode.physicsBody!, wheels: [wheelFL, wheelFR, wheelBL, wheelBR])
        scene.physicsWorld.addBehavior(vehicle)
        
        return (chassisNode)
        
    }
    
    print("⁉️ FAILED TO FIND CHASSIS...")
    return SCNNode()
    
}

func addCameraCarConstraints(scene: SCNScene) -> [SCNConstraint] {
    guard let carNode = scene.rootNode.childNode(withName: "CHASSIS", recursively: true) else {
        fatalError("CHASSIS node not found in the scene.")
    }
    
    guard let targetNode = carNode.childNode(withName: "target", recursively: true) else {
        fatalError("Target node not found in CHASSIS.")
    }
    
    guard let cameraParentNode = carNode.childNode(withName: "cameraParent", recursively: true) else {
        fatalError("CameraParent node not found in CHASSIS.")
    }

    // CameraConstraints
    let lookAtConstraint = SCNLookAtConstraint(target: targetNode)
    lookAtConstraint.isGimbalLockEnabled = true
    lookAtConstraint.influenceFactor = 0.7

    let positionConstraint = SCNDistanceConstraint(target: cameraParentNode)
    positionConstraint.maximumDistance = 4
    positionConstraint.minimumDistance = 0
    
    let accelerationConstraint = SCNAccelerationConstraint()
    accelerationConstraint.maximumLinearVelocity = 3500.0
    accelerationConstraint.maximumLinearAcceleration = 400
    accelerationConstraint.damping = 0.05
    accelerationConstraint.decelerationDistance = 1

    // Return the array of constraints
    return [lookAtConstraint, positionConstraint, accelerationConstraint]
}

func departurePos(nodeBindingData: NodeData, nodeTree: WebGraph) -> SCNVector3 {
    if let departureWebNode = nodeTree.getNode(name: "locationNode".appending(nodeBindingData.selectedDepartureNode)) {
        let depPos = SCNVector3(departureWebNode.xpos, 2, departureWebNode.zpos)
        
        return depPos
    }
    return SCNVector3(x: 0, y: 2, z: 0)
}

func destinationPos(nodeBindingData: NodeData, nodeTree: WebGraph) -> SCNVector3 {
    if let departureWebNode = nodeTree.getNode(name: "locationNode".appending(nodeBindingData.selectedDestinationNode)) {
        let depPos = SCNVector3(departureWebNode.xpos, 2, departureWebNode.zpos)
        
        return depPos
    }
    return SCNVector3(x: 0, y: 2, z: 0)
}


func addCarConsolidated(startedDriving: inout Bool, scene: SCNScene, sceneView: SCNView, carBindingData: CarData, disableDrive: inout Bool, nodeBindingData: NodeData, nodeTree: WebGraph) {
    if startedDriving == false {
        
        if let departureWebNode = nodeTree.getNode(name: "locationNode".appending(nodeBindingData.selectedDepartureNode)) {
            
            //addSphere(scene: scene, x: Float(departureWebNode.xpos), y: 0, z: departureWebNode.zpos, size: 8, color: .blue, name: "sphere")
            
            let depPos = SCNVector3(departureWebNode.xpos, 2, departureWebNode.zpos)
            
            addCar(scene: scene, bindingData: carBindingData, pos: depPos)
            
            //let carcamera = scene.rootNode.childNode(withName: "carcam", recursively: true)
            
            let carcamera = sceneView.pointOfView
            
            let constraints = addCameraCarConstraints(scene: scene)
            carcamera?.position = SCNVector3(0, 0, 0)
            carcamera?.constraints = constraints
            sceneView.pointOfView = carcamera
            startedDriving = true
            disableDrive = true
                
            startedDriving = true
            
        } else {
            print("Could not find depNode")
        }
    } else {
        print("Car Created")
    }
}


// Not all of this code is needed, but i was running into issues and didn't have time to optimize or find the culprit... This works...
func removeCarConsolidated(scene: SCNScene, sceneView: SCNView) {
    if let originalCamera = scene.rootNode.childNode(withName: "cameraNode", recursively: true) {

        let ogcam = sceneView.pointOfView
        ogcam!.constraints = []
        
        ogcam!.parent!.worldPosition = SCNVector3(0, 0, 0)
        ogcam!.parent!.position = SCNVector3(0, 0, 0)
        ogcam!.parent!.eulerAngles = SCNVector3(0, 0, 0)
        
        ogcam!.rotation = SCNVector4(x: -1.0, y: -1.5842070766325378e-08, z: 1.5842070766325378e-08, w: 1.5707963705062866)
        ogcam!.eulerAngles = SCNVector3(x: -1.5707963705062866, y: 0.0, z: 3.1684141532650756e-08)
        //ogcam!.position = SCNVector3(x: 0.0, y: 1205.490234375, z: 0.0)
        ogcam!.worldPosition = SCNVector3(x: 0.0, y: 10, z: 0.0)
        
        ogcam!.parent!.worldPosition = SCNVector3(0, 1000, 0)
        //ogcam!.parent!.position = SCNVector3(x: 0.0, y: 1205.490234375, z: 0.0)
        ogcam!.parent!.eulerAngles = SCNVector3(0, 0, 0)
        
        originalCamera.position = SCNVector3(0, 0, 0)
        originalCamera.worldPosition = SCNVector3(x: 0.0, y: 1000, z: 0.0)
        
        
        
    } else {
        print("Didn't find original camera")
    }
    
    let chassisNode = scene.rootNode.childNode(withName: "CHASSIS", recursively: true)
    chassisNode?.removeFromParentNode()

    }


func moveCar(scene: SCNScene, pos: SCNVector3) {
    let car = scene.rootNode.childNode(withName: "CHASSIS", recursively: true)
    car!.position = pos
}
