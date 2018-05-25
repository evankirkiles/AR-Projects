//
//  SKContainerOverlay.swift
//  ARBall
//
//  Created by Evan Kirkiles on 8/22/17.
//  Copyright © 2017 Evan Kirkiles. All rights reserved.
//

import UIKit
import SpriteKit

class SKContainerOverlay: SKScene {
    
    class func createHud(withSize size: CGSize) -> SKScene {
        let scene = SKScene(size: size)
        scene.backgroundColor = UIColor.clear
        
        let button = SKSpriteNode.init(imageNamed: "art.scnassets/explosion5.png")
        button.size = CGSize(width: 50, height: 50)
        button.position = CGPoint(x: size.width * 0.1, y: size.height * 0.1)
        
        scene.addChild(button)
        return scene
    }
}
