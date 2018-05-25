//
//  Animations.swift
//  ARBall
//
//  Created by Evan Kirkiles on 8/21/17.
//  Copyright © 2017 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit

class Animations: NSObject {
    
    class func fadeOutAndIn() -> SCNAction {
        let parentAnimation = SCNAction.sequence([SCNAction.fadeIn(duration: 0.1), SCNAction.fadeOut(duration: 0.1), SCNAction.fadeIn(duration: 0.1), SCNAction.fadeOut(duration: 0.1), SCNAction.fadeIn(duration: 0.1), SCNAction.fadeOut(duration: 0.1), SCNAction.fadeIn(duration: 0.1), SCNAction.fadeOut(duration: 0.1), SCNAction.fadeIn(duration: 0.1), SCNAction.fadeOut(duration: 0.1)])
        return parentAnimation
    }
}
