//
//  Plugboard.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SwiftUI
import SpriteKit

/// Plugboard Swift UI View
struct Plugboard: View {

    static let notificationName = Notification.Name("myNotificationName")
    static let removeNotification = Notification.Name("removeNotificationName")

    private var scene: PlugboardSimulation {
        let scene = PlugboardSimulation()
        scene.size = CGSize(width: 405, height: 165)
        scene.scaleMode = .fill
        return scene
    }

    var body: some View {
        VStack {
            CText(text: "Plugboard", font: .title, weight: .bold)
                .multilineTextAlignment(.center)
                .padding(insets: [0,5,0,5])
                .offset(y: 10)

            SpriteView(scene: scene)
                .frame(width: 405, height: 165)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(10)
        }
    }
}
