//
//  PlugboardSimulation.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SpriteKit

/// Plugboard Swift UI Scene
final class PlugboardSimulation: PlugboardProtocol {
    private var wiresRemaining = 10
    private var wiresarr = [SKShapeNode]()

    override internal func didMove(to view: SKView) {
        self.backgroundColor = #colorLiteral(red: 0.1021424755, green: 0.1021673307, blue: 0.1021392122, alpha: 1)
        wiresRemaining = 10
        width = 36
        generalSetup(offset: 12)

        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: Plugboard.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeNotification(notification:)), name: Plugboard.removeNotification, object: nil)
    }

    @objc private func onNotification(notification:Notification) {
        let result = notification.userInfo!["id"] as! String

        let components = result.components(separatedBy: "-")
        createLine(start: components[0], end: components[1])
    }
    @objc private func removeNotification(notification:Notification) {
        let result = notification.userInfo!["id"] as! Bool
        if result != true { return }

        let action = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
        for node in wiresarr {
            node.run(action)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            for node in self.wiresarr {
                node.removeFromParent()
            }
            self.wiresRemaining = 10
        }
    }

    private func createLine(start: String, end: String) {
        if start == "-" || end == "-" { return }
        if wiresRemaining == 0 { wiresRemaining = 10 }

        let startNode = self.childNode(withName: start)!
        let endNode = self.childNode(withName: end)!
        let line = SKShapeNode(start: startNode.position, end: endNode.position, strokeColor: PlugboardSimulation.colours[wiresRemaining-1], lineWidth: 5.0)
        line.alpha = 0.0
        line.zPosition = -5
        addChild(line)
        wiresRemaining -= 1

        wiresarr.append(line)
        line.run(SKAction.fadeIn(withDuration: 1.0))
    }
}
