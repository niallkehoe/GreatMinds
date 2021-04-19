//
//  EnigmaMachine.swift
//  BookCore
//
//  Created by Niall Kehoe on 02/04/2021.
//

import SceneKit

/// Enigma Node
final class EnigmaMachine : SCNNode {

    private var scene: SCNScene!
    internal var lightNode: SCNNode = SCNNode()

    public init(scene :SCNScene) {
        super.init()
        self.scene = scene
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)

        let rocketNode = self.scene.rootNode
        self.addChildNode(rocketNode)

        lightNode = (self.scene?.rootNode.childNode(withName: "Lights", recursively: true))!
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
