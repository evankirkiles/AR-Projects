//
//  Nodes.swift
//  AR Ruler
//
//  Created by Evan Kirkiles on 5/24/18.
//  Copyright © 2018 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit

class Nodes: NSObject {

    class func getNode() -> SCNNode {
        // Create hoopNode
        let node = SCNNode(geometry: SCNBox(width: 0.005, height: 0.005, length: 0.005, chamferRadius: 0))
        node.geometry?.firstMaterial?.diffuse.minificationFilter = SCNFilterMode.nearest
        node.geometry?.firstMaterial?.diffuse.magnificationFilter = SCNFilterMode.nearest
        
        return node
    }
    
    class func getDistanceDisplayNode() -> SCNNode {
        let displayNode = SCNNode(geometry: SCNPlane(width: 0.16, height: 0.128))
        displayNode.position = SCNVector3(0, 0.31716, -0.11853)
        displayNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        
        let displayText = SCNText.init(string: "0m", extrusionDepth: 0)
        displayText.font = UIFont(name: "AvenirNext-Medium", size: 100)
        let displayTextNode = SCNNode(geometry: displayText)
        center(node: displayTextNode)
        displayTextNode.scale = SCNVector3(0.0016, 0.00128, 0)
        displayTextNode.position = SCNVector3(0, 0, 0.01)
        displayTextNode.name = "distancetext"
        displayNode.addChildNode(displayTextNode)
        let billboardconstraint = SCNBillboardConstraint()
        billboardconstraint.freeAxes = SCNBillboardAxis.Y
        displayNode.constraints = [billboardconstraint]
        displayNode.name = "distancenode"
        
        return displayNode
    }
    
    class func center(node: SCNNode) {
        let (min, max) = node.boundingBox
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        node.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    }
}
