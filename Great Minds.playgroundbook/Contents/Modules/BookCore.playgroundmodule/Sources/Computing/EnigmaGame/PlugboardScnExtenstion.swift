//
//  PlugboardScnExtenstion.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SpriteKit

/// Plugboard Base Scene
class PlugboardProtocol : SKScene {
    
    private static let letters = ["q", "w", "e", "r", "t", "z", "u", "i", "o", "a", "s", "d", "f", "g", "h", "j", "k", "p", "y", "x", "c", "v", "b", "n", "m", "l"]
    private var positions1x : [CGFloat] = [0,0,0,0,0,0,0,0,0]
    private var positions2x : [CGFloat] = [0,0,0,0,0,0,0,0,0]
    internal var width : CGFloat = 36
    internal var nodes = [LetterNode]()
    internal static let colours : [UIColor] = [#colorLiteral(red: 0.595808506, green: 0.5956688523, blue: 0.9466395974, alpha: 1), #colorLiteral(red: 0.997454226, green: 0.3151476979, blue: 0.3228361905, alpha: 1), #colorLiteral(red: 0.9792943597, green: 0.5557171702, blue: 0.2024151683, alpha: 1), #colorLiteral(red: 0.9822317958, green: 0.2030612826, blue: 0.951395452, alpha: 1), #colorLiteral(red: 0, green: 0.5947859883, blue: 0.5107073784, alpha: 1), #colorLiteral(red: 0.6841385961, green: 0.193421036, blue: 1, alpha: 1), #colorLiteral(red: 0.8460288644, green: 1, blue: 0.2880074084, alpha: 1) , #colorLiteral(red: 0.1558483243, green: 0.4354070425, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0.337780416, alpha: 1), #colorLiteral(red: 0, green: 1, blue: 0.5543081164, alpha: 1)]
    
    internal func generalSetup(offset: CGFloat = 0) {
        let spacing = (self.size.width-(9*width)) / 10
        let centre : CGFloat = size.width/2
        
        //Create Popup instructional video
        
        for indx in 0...8 {
            positions1x[indx] = centre + ((spacing + width)*CGFloat(indx-4))
            createNode(offset: offset, ltr: PlugboardScn.letters[indx], itm: indx, row: 0)
            createNode(offset: offset, ltr: PlugboardScn.letters[indx+17], itm: indx, row: 2)
            
            if indx == 8 { return }
            positions2x[indx] = centre + ((spacing + width)*(2*(CGFloat(indx)-3.5))/2)
            createNode(offset: offset, ltr: PlugboardScn.letters[indx+9], itm: indx, row: 1)
        }
    }
}

internal extension PlugboardProtocol {
    final func createNode(offset: CGFloat = 0, ltr: String, itm: Int, row: Int) {
        let node = LetterNode(letter: ltr)
        node.name = ltr
        node.isUserInteractionEnabled = false

        node.size = CGSize(width: width, height: width)
        if row == 0 {
            node.position = CGPoint(x: positions1x[itm], y: offset == 0 ? 30 + (width*5/2): self.size.height - 20 - (width/2) + offset)
        } else if row == 1 {
            node.position = CGPoint(x: positions2x[itm], y: offset == 0 ? 20 + (width*3/2): self.size.height/2)
        } else {
            node.position = CGPoint(x: positions1x[itm], y: offset == 0 ? 10 + (width/2): (width/2) + offset)

        }
        nodes.append(node)

        self.addChild(node)
    }
}
