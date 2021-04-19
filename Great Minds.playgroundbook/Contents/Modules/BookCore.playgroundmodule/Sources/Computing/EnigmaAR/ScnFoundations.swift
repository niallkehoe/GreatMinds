//
//  SceneFoundations.swift
//  BookCore
//
//  Created by Niall Kehoe on 02/04/2021.
//

import SceneKit

// MARK: - Camera Class
internal final class Camera {
    var position: SCNVector3
    var rotation: SCNVector3
    var name: String

    init(position: SCNVector3, rotation: SCNVector3, name: String) {
        self.position = position
        self.rotation = rotation
        self.name = name
    }
}

// MARK: - CameraSetup
internal final class CameraSetup {
    var normalCamera: Camera
    var plugboardCamera: Camera
    var keyboardCamera: Camera

    init(cam1: SCNNode, cam2: SCNNode, cam3: SCNNode) {
        self.normalCamera = Camera(position: cam1.position, rotation: SCNVector3(-30.533, -52.769, 0.681).degreesToRadians(), name: "camera")
        self.plugboardCamera = Camera(position: cam2.position, rotation: SCNVector3(180, -90, -180).degreesToRadians(), name: "plugboard")
        self.keyboardCamera = Camera(position: cam3.position, rotation: SCNVector3(-90, -90, 0).degreesToRadians(), name: "keyboard")
    }
}

// MARK: - Encryption

internal final class Mappings {
    
    /// Letter to Index Dictionary
    let charsToNumbers : [String:Int] = ["a":0,"b":1,"c":2,"d":3,"e":4,"f":5,"g":6,"h":7,"i":8,"j":9,"k":10,"l":11,"m":12,"n":13,"o":14,"p":15,"q":16,"r":17,"s":18,"t":19,"u":20,"v":21,"w":22,"x":23,"y":24,"z":25]

    /// Randomly generated mappings for Rotor 1
    let mapping1 = [0:13,
                    1:6,
                    2:24,
                    3:25,
                    4:0,
                    5:14,
                    6:19,
                    7:16,
                    8:10,
                    9:1,
                    10:15,
                    11:12,
                    12:18,
                    13:23,
                    14:8,
                    15:11,
                    16:20,
                    17:2,
                    18:4,
                    19:7,
                    20:9,
                    21:3,
                    22:22,
                    23:25,
                    24:17,
                    25:21]

    /// Randomly generated mappings for Rotor 2
    var mapping2 = [0:9,
                    1:6,
                    2:20,
                    3:8,
                    4:19,
                    5:10,
                    6:15,
                    7:2,
                    8:5,
                    9:0,
                    10:7,
                    11:4,
                    12:25,
                    13:12,
                    14:22,
                    15:17,
                    16:14,
                    17:11,
                    18:23,
                    19:18,
                    20:21,
                    21:16,
                    22:1,
                    23:3,
                    24:13,
                    25:24]
}

/// Get Key for Value in Dictonary
internal extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

/// SCNVector3 Degrees To Radians Conversion
internal extension SCNVector3 {
    func degreesToRadians() -> SCNVector3 {
        return SCNVector3(x: self.x * Float.pi / 180.0, y: self.y * Float.pi / 180.0, z: self.z * Float.pi / 180.0)
    }
}
