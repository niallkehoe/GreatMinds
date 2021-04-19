//
//  CustomExtensions.swift
//  BookCore
//
//  Created by Niall Kehoe on 03/04/2021.
//

import SpriteKit

// MARK: SpriteKit Extensions
final class LetterNode: SKSpriteNode {
    internal var isEngaged : Bool = false
    private let ypos : [CGFloat] = [-2,-2,-2,-2,-1,-2,-4,-2,-3,
                                    -2,-2,-2,0,-3,0,-1,0,
                                    -2,-4,-2,-2,-2,-2,-3,-3,-1]
    private let charsToNumbers : [String:Int] = ["q":0,"w":1,"e":2,"r":3,"t":4,"z":5,"u":6,"i":7,"o":8,"a":9,"s":10,"d":11,"f":12,"g":13,"h":14,"j":15,"k":16,"p":17,"y":18,"x":19,"c":20,"v":21,"b":22,"n":23,"m":24,"l":25]
    
    init(letter: String) {
        super.init(texture: SKTexture(imageNamed: "circle"), color: .blue, size: CGSize(width: 36, height: 36))
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.position.y = ypos[charsToNumbers[letter]!]
        
        label.text = letter
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.fontSize = 20.0
        label.zPosition = 1
        self.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SKShapeNode {
    convenience init(start: CGPoint, end: CGPoint, strokeColor: UIColor, lineWidth: CGFloat) {
        self.init()

        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)

        self.path = path
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }
}
