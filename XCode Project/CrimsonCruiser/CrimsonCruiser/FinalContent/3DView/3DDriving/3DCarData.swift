//
//  3DCarData.swift
//  CrimsonCruiser
//
//  Created by Konstantin Freiherr von Stein on 12/3/24.
//

import Foundation

struct CarData: Equatable {
    var steeringAngle: CGFloat
    var speed: CGFloat
    var braking: Bool
    var accelerating: Bool
    var reversing: Bool
    var mass: CGFloat
    var suspensionStiffness: CGFloat
    var suspensionHeight: CGFloat
    var friction: CGFloat

    init(steeringAngle: CGFloat, speed: CGFloat, braking: Bool, accelerating: Bool, reversing: Bool, mass: CGFloat, suspensionStiffness: CGFloat, suspensionHeight: CGFloat, friction: CGFloat) {
        self.steeringAngle = steeringAngle
        self.speed = speed
        self.braking = braking
        self.accelerating = accelerating
        self.reversing = reversing
        self.mass = mass
        self.suspensionStiffness = suspensionStiffness
        self.suspensionHeight = suspensionHeight
        self.friction = friction
    }
    
}
