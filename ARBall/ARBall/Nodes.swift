//
//  Nodes.swift
//  ARBall
//
//  Created by Evan Kirkiles on 8/21/17.
//  Copyright © 2017 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class Nodes: NSObject {

    class func getHoopNode() -> SCNNode {
        // Create hoopNode
        let hoopNode = SCNScene(named: "art.scnassets/hoop.dae")?.rootNode.childNode(withName: "hoop", recursively: true)
        hoopNode?.geometry?.firstMaterial?.diffuse.minificationFilter = SCNFilterMode.nearest
        hoopNode?.geometry?.firstMaterial?.diffuse.magnificationFilter = SCNFilterMode.nearest
        
        return hoopNode!
    }
    
    class func getBasketDetectionNode() -> SCNNode {
        let planes = SCNNode()
    
        // Create top plane
        let plane1 = SCNNode()
        plane1.eulerAngles = SCNVector3(GLKMathDegreesToRadians(-90.0), 0, 0)
        plane1.position = SCNVector3(0, 0.01770, 0.01835)
        plane1.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape.init(geometry: SCNPlane(width: 0.136, height: 0.136)))
        plane1.physicsBody?.isAffectedByGravity = false
        plane1.name = "top plane"
        plane1.physicsBody?.categoryBitMask = ViewController.TOPPLANE_CATEGORY
        plane1.physicsBody?.collisionBitMask = ViewController.NOCOLLISION
        plane1.physicsBody?.contactTestBitMask = ViewController.NOCOLLISION
        
        // Create bottom plane
        let plane2 = SCNNode()
        plane2.eulerAngles = SCNVector3(GLKMathDegreesToRadians(-90.0), 0, 0)
        plane2.position = SCNVector3(0, -0.06145, 0.01835)
        plane2.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape.init(geometry: SCNPlane(width: 0.136, height: 0.136)))
        plane2.physicsBody?.isAffectedByGravity = false
        plane2.name = "bottom plane"
        plane2.physicsBody?.categoryBitMask = ViewController.BOTPLANE_CATEGORY
        plane2.physicsBody?.collisionBitMask = ViewController.NOCOLLISION
        plane2.physicsBody?.contactTestBitMask = ViewController.NOCOLLISION
        
        // Add planes to parent plane node and return it
        planes.addChildNode(plane1)
        planes.addChildNode(plane2)
        return planes
    }
    
    class func getHoopGeometryNode() -> SCNNode {
        // Create the torus of cylinders that is the hoop
        let parent = SCNNode()
        parent.addChildNode(createCylinder(position: SCNVector3(0.08785, -0.00943, 0.00806), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), 0, 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(0.07489, -0.00943, 0.05592), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(-38.192), 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(0.03598, -0.00943, 0.08917), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(-68.521), 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(0, -0.00943, 0.09835), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(90.0), 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(-0.03598, -0.00943, 0.08917), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(68.521), 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(-0.07489, -0.00943, 0.05592), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(38.192), 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(-0.08785, -0.00943, 0.00806), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), 0, 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(-0.06950, -0.00943, -0.04057), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(-38.192), 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(-0.028, -0.00943, -0.0731), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(-68.521), 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(0.028, -0.00943, -0.0731), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(68.521), 0)))
        parent.addChildNode(createCylinder(position: SCNVector3(0.0695, -0.00943, -0.04192), eulerAngles: SCNVector3(GLKMathDegreesToRadians(90.0), GLKMathDegreesToRadians(38.192), 0)))
        
        // Create the backboard
        let backboard = SCNNode(geometry: SCNBox(width: 0.309, height: 0.256, length: 0.024, chamferRadius: 0))
        backboard.position = SCNVector3(0, 0.06333, -0.08441)
        parent.addChildNode(backboard)
        
        return parent
    }
    
    class func createCylinder(position: SCNVector3, eulerAngles: SCNVector3) -> SCNNode {
        let newCylinder = SCNNode(geometry: SCNCylinder(radius: 0.021, height: 0.059))
        newCylinder.position = position
        newCylinder.eulerAngles = eulerAngles
        return newCylinder
    }
    
    class func getBasketMadeNode() -> SCNNode {
        let textNode = SCNNode(geometry: SCNPlane(width: 0.674, height: 0.54))
        textNode.position = SCNVector3(0, 0.05858, -0.11853)
        textNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/explosion5.png")
        textNode.name = "winner"
        return textNode
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
    
    class func makeFloorPlane(node: SCNNode, anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                             height:CGFloat(planeAnchor.extent.z))
        
        node.position = SCNVector3(CGFloat(planeAnchor.center.x),
                                        CGFloat(planeAnchor.center.y),
                                        CGFloat(planeAnchor.center.z))
        node.eulerAngles.x = -.pi / 2
        
        node.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape.init(geometry: plane))
        node.physicsBody?.isAffectedByGravity = false
        node.name = "collision plane"
        node.physicsBody?.categoryBitMask = ViewController.SOLID_CATEGORY
        node.physicsBody?.collisionBitMask = ViewController.BALL_CATEGORY
    }
    
    class func createGround() -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(10000),
                             height: CGFloat(10000))
        let node = SCNNode()
        node.position = SCNVector3(CGFloat(0),
                                   CGFloat(-1.5),
                                   CGFloat(0))
        node.eulerAngles.x = .pi / 2
        
        node.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape.init(geometry: plane))
        node.physicsBody?.isAffectedByGravity = false
        node.name = "collision plane"
        node.physicsBody?.categoryBitMask = ViewController.SOLID_CATEGORY
        node.physicsBody?.collisionBitMask = ViewController.BALL_CATEGORY
        
        return node
    }
}
