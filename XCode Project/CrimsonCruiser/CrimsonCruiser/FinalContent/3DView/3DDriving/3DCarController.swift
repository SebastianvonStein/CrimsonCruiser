//
//  3DDrivingFunctions.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 12/2/24.
//


import Foundation
import SceneKit
import SwiftUI

func carController(view: SCNView, bindingData: CarData) {
    
    var localEngineForce: CGFloat = 0
    var localBrakingForce: CGFloat = 0
    
    let vehicleController = view.scene?.physicsWorld.allBehaviors.first as? SCNPhysicsVehicle
    let speed = vehicleController?.speedInKilometersPerHour ?? 0
    let chassisNode = view.scene?.rootNode.childNode(withName: "CHASSIS", recursively: false)
    //let gearinfo = view.scene?.rootNode.childNode(withName: "gearInfo", recursively: false)
    //let cameraNode = view.pointOfView
    
    if bindingData.accelerating == true {
        localEngineForce = speedFunction(speed: speed, isDriving: bindingData.accelerating, scene: view)
    } else {
        localEngineForce = 0
    }
    
    if bindingData.braking == true {
        localBrakingForce = 28
    } else {
        localBrakingForce = 0
    }
    
    if bindingData.reversing == true {
        localEngineForce = -380
    } else {
        if bindingData.accelerating == false {
            localEngineForce = 0
        }
    }
    
    // chassisNode?.worldPosition = SCNVector3(x: 0, y: 4, z: 0)
    chassisNode?.physicsBody?.mass = bindingData.mass
    
    vehicleController?.applyEngineForce(localEngineForce/5, forWheelAt: 0)
    vehicleController?.applyEngineForce(localEngineForce/5, forWheelAt: 1)
    vehicleController?.applyEngineForce(localEngineForce, forWheelAt: 2)
    vehicleController?.applyEngineForce(localEngineForce, forWheelAt: 3)
    //print(localEngineForce.description)

    vehicleController?.applyBrakingForce(localBrakingForce, forWheelAt: 0)
    vehicleController?.applyBrakingForce(localBrakingForce, forWheelAt: 1)
    vehicleController?.applyBrakingForce(localBrakingForce * 0.6, forWheelAt: 2)
    vehicleController?.applyBrakingForce(localBrakingForce * 0.6, forWheelAt: 3)
    //print(localBrakingForce.description)
    
    vehicleController?.setSteeringAngle(bindingData.steeringAngle, forWheelAt: 1)
    vehicleController?.setSteeringAngle(bindingData.steeringAngle, forWheelAt: 0)
    //print(bindingData.steeringAngle.description)
    
    vehicleController?.wheels[0].suspensionStiffness = bindingData.suspensionStiffness
    vehicleController?.wheels[1].suspensionStiffness = bindingData.suspensionStiffness
    vehicleController?.wheels[2].suspensionStiffness = bindingData.suspensionStiffness
    vehicleController?.wheels[3].suspensionStiffness = bindingData.suspensionStiffness
    
    vehicleController?.wheels[0].suspensionRestLength = bindingData.suspensionHeight
    vehicleController?.wheels[1].suspensionRestLength = bindingData.suspensionHeight
    vehicleController?.wheels[2].suspensionRestLength = bindingData.suspensionHeight
    vehicleController?.wheels[3].suspensionRestLength = bindingData.suspensionHeight
    
    vehicleController?.wheels[0].frictionSlip = bindingData.friction
    vehicleController?.wheels[1].frictionSlip = bindingData.friction
    vehicleController?.wheels[2].frictionSlip = bindingData.friction - 0.05
    vehicleController?.wheels[3].frictionSlip = bindingData.friction - 0.05
     
    
}

func speedFunction(speed: CGFloat, isDriving: Bool, scene: SCNView) -> CGFloat {
    
    let gearData: [(minSpeed: CGFloat, maxSpeed: CGFloat, engineForce: CGFloat, gear: Float)] =
    [
        (minSpeed: -100, maxSpeed: 30, engineForce: 250, gear: 1),
        (minSpeed: 30.2, maxSpeed: 50, engineForce: 240, gear: 2),
        (minSpeed: 50.2, maxSpeed: 75, engineForce: 210, gear: 3),
        (minSpeed: 75.2, maxSpeed: 100, engineForce: 170, gear: 4),
        (minSpeed: 100.1, maxSpeed: 125, engineForce: 160, gear: 5),
        (minSpeed: 125.05, maxSpeed: .greatestFiniteMagnitude, engineForce: 150, gear: 6)
    ]

    var outputEngineForce: CGFloat = 0
    var currentGear: Float = 0
    let gearinfo = scene.scene?.rootNode.childNode(withName: "gearInfo", recursively: false)

    if isDriving {
        for (_, gearDataSet) in gearData.enumerated() {
           if speed >= gearDataSet.minSpeed && speed <= gearDataSet.maxSpeed {
               currentGear = gearDataSet.gear
               /*
               if gearinfo?.position.y != currentGear {
                  // gearShift()
               }
               */
               outputEngineForce = gearDataSet.engineForce
               #if os(iOS)
               gearinfo?.position.y = Float(currentGear)
               #elseif os(macOS)
               gearinfo?.position.y = CGFloat(currentGear)
               #endif
               break
           }
       }
    } else {

    }
    return outputEngineForce * 6
}

