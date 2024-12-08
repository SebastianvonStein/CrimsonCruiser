//
//  KeyPressHandler.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 12/5/24.
//

import Foundation
import SwiftUI
import SceneKit

func handlePress (press: KeyPress, pressedKeys: inout [Bool], pos: SCNVector3, scene: SCNScene, sceneView: SCNView, startedDriving: inout Bool) -> KeyPress.Result {
    if press.phase == .down {
        if press.key.character.debugDescription.contains("w") {
            pressedKeys[0] = true}
        if press.key.character.debugDescription.contains("a") {
            pressedKeys[1] = true}
        if press.key.character.debugDescription.contains("s") {
            pressedKeys[2] = true}
        if press.key.character.debugDescription.contains("d") {
            pressedKeys[3] = true}
        if press.key.character.debugDescription.contains("x") {
            pressedKeys[4] = true}
    
        if press.key.character.debugDescription.contains("r") {
            moveCar(scene: scene, pos: pos)
        }
        
        if press.key.character.debugDescription.contains("q") {
            removeCarConsolidated(scene: scene, sceneView: sceneView)
            startedDriving = false
        } }
    
    if press.phase == .up {
        if press.key.character.debugDescription.contains("w") {
            pressedKeys[0] = false }
        if press.key.character.debugDescription.contains("a") {
            pressedKeys[1] = false }
        if press.key.character.debugDescription.contains("s") {
            pressedKeys[2] = false }
        if press.key.character.debugDescription.contains("d") {
            pressedKeys[3] = false }
        if press.key.character.debugDescription.contains("x") {
            pressedKeys[4] = false }
    }
    return .handled
}

func handleDrivingStateFromKeys(press: [Bool], carBindingData: inout CarData) {
    // Pressed Handle
    if press[0] == true {
        carBindingData.accelerating = true
    }
    if press[1] == true {
        if carBindingData.steeringAngle <= 0.6 {
            carBindingData.steeringAngle += 0.06
        }
    }
    if press[2] == true {
        carBindingData.braking = true
    }
    if press[3] == true {
        if carBindingData.steeringAngle >= -0.6 {
            carBindingData.steeringAngle += -0.06
        }
    }
    
    if press[4] == true {
        carBindingData.reversing = true
    }
    
    // Not Pressed Handel
    if press[0] == false {
        carBindingData.accelerating = false
    }
    if press[1] == false && press[3] == false{
        if carBindingData.steeringAngle > 0 {
            carBindingData.steeringAngle += -0.06
        } else if carBindingData.steeringAngle < 0 {
            carBindingData.steeringAngle += 0.06
        } else {
            carBindingData.steeringAngle = 0
        }
    }
    if press[2] == false {
        carBindingData.braking = false
    }
    if press[4] == false {
        carBindingData.reversing = false
    }
}
