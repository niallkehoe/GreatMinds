//
//  PlugboardScn.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SpriteKit

/// Plugboard Wiring Scene
final class PlugboardScn: PlugboardProtocol {

    var passVC: ViewController?
    
    private var wiresLabel: SKLabelNode!
    internal var wiresRemaining = 10
    private var startNode : LetterNode!

    private var lineinProgress : SKShapeNode?
    private var drawinginProgress = false
    private var lines = [SKShapeNode]()

    override func didMove(to view: SKView) {
        self.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        width = 32
        generalSetup()

        let title = createLabel(text: "Plugboard", y: self.size.height*0.89, fontSize: 35, fontName: "AvenirNext-Bold")
        self.addChild(title)

        wiresLabel = createLabel(text: "Wires Remaining: 10", y: self.size.height*0.73, fontSize: 15, fontName: "AvenirNext-Medium")
        self.addChild(wiresLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: self)
        for indx in 0...25 {
            if nodes[indx].contains(location!) {
                if !nodes[indx].isEngaged {
                    if wiresRemaining > 0 {
                        startNode = nodes[indx]
                        createLine(location: location!)
                        drawinginProgress = true
                    }
                }
            }
        }

    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if drawinginProgress == true {
            let location = touches.first?.location(in: self)
            createLine(location: location!)
        }

    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if drawinginProgress == true {
            let location = touches.first?.location(in: self)
            for indx in 0...25 {
                if nodes[indx].contains(location!) {
                    if !nodes[indx].isEngaged && startNode != nodes[indx] {
                        createLine(location: nodes[indx].position) // Lock on centre
                        lineinProgress?.zPosition = -5
                        lines.append(lineinProgress!)
                        lineinProgress = nil
                        startNode.isEngaged = true
                        nodes[indx].isEngaged = true
                        drawinginProgress = false
                        updateWireLabel()
                        return
                    }
                }
            }
            lineinProgress?.removeFromParent()
        }
        drawinginProgress = false
    }


    private func createLine(location: CGPoint) {
        if lineinProgress != nil {
            lineinProgress?.removeFromParent()
        }
        lineinProgress = SKShapeNode(start: startNode.position, end: location, strokeColor: PlugboardScn.colours[wiresRemaining-1], lineWidth: 5.0)
        addChild(lineinProgress!)
    }

    private func updateWireLabel() {
        wiresRemaining -= 1
        wiresLabel.text = "Wires Remaining: \(wiresRemaining)"

        if wiresRemaining == 0 {
            //Display Alert Congradulations
            passVC?.sucessfullyWiredBox()
        }
    }
}

extension PlugboardScn {
    private final func createLabel(text: String, y: CGFloat, fontSize: CGFloat, fontName: String) -> SKLabelNode {
        let title = SKLabelNode(fontNamed: fontName)
        title.text = text
        title.position = CGPoint(x: self.size.width/2, y: y)
        
        title.fontColor = .white
        title.verticalAlignmentMode = .center
        title.fontSize = fontSize
        return title
    }
}
