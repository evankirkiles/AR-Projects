//
//  ViewController.swift
//  ARBall
//
//  Created by Evan Kirkiles on 8/20/17.
//  Copyright © 2017 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    static let NOCOLLISION = 0
    static let BALL_CATEGORY = 1
    static let SOLID_CATEGORY = 2
    static let TOPPLANE_CATEGORY = 4
    static let BOTPLANE_CATEGORY = 16
    
    var hoopNode: SCNNode?
    var basketball: SCNNode?
    var distanceDisplay: SCNNode?
    
    var containerOverlay: SKScene?
    
    var basketPlaced = false
    var holdingBasketball = false
    var thrownBasketball = false
    var deleteBasketball = false

    var passedThroughTopPlane = false
    var basketScored = false
    
    var startTouch: CGPoint?
    var intermediateTouch: CGPoint?
    var startTime: TimeInterval?
    var beingTouched = false
    
    static let kMinDistance = 25
    static let kMinDuration = 0.05
    static let kMinSpeed = 100
    static let kMaxSpeed = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Set properties of the sceneView and physicsWorld
        sceneView.scene.physicsWorld.gravity = SCNVector3Make(0.0, -3.0, 0.0)
        
        /*
        // Create the HUD
        containerOverlay = SKContainerOverlay.createHud(withSize: sceneView.bounds.size)
        
        // Add the HUD as an overlay
        sceneView.overlaySKScene = containerOverlay
        sceneView.overlaySKScene?.isHidden = false
        sceneView.overlaySKScene?.scaleMode = .resizeFill
        sceneView.overlaySKScene?.isUserInteractionEnabled = false
        */
 
        // Initialize the hoop
        hoopNode = Nodes.getHoopNode()
        hoopNode?.geometry?.firstMaterial?.transparency = 0.5
        sceneView.scene.rootNode.addChildNode(hoopNode!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if basket has been placed
        if (!basketPlaced) {

            // Anchor nonplaced hoop
            hoopNode?.geometry?.firstMaterial?.transparency = 1

            // Create hoopNode's physicsbody
            hoopNode?.physicsBody = SCNPhysicsBody.init(type: SCNPhysicsBodyType.static, shape: SCNPhysicsShape.init(node: Nodes.getHoopGeometryNode(), options: [SCNPhysicsShape.Option.keepAsCompound : true]))
            hoopNode?.physicsBody?.isAffectedByGravity = false
            hoopNode?.physicsBody?.categoryBitMask = ViewController.SOLID_CATEGORY
            hoopNode?.physicsBody?.collisionBitMask = ViewController.BALL_CATEGORY
            hoopNode?.addChildNode(Nodes.getBasketDetectionNode())
            
            hoopNode?.addChildNode(Nodes.createGround())
            hoopNode?.addChildNode(Nodes.getDistanceDisplayNode())
            basketPlaced = true
        }
        
        // Get the start location of the swipe
        startTouch = touches.first?.location(in: self.view)
        startTime = touches.first?.timestamp
        beingTouched = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        intermediateTouch = touches.first?.location(in: self.view)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var speed: Float?
        var isSwipe = false
        // Check if the touch IS a swipe, and get its distance and speed
        let endTouch = touches.first?.location(in: self.view)
        let dx: Float = Float(endTouch!.x - (startTouch?.x)!)
        let dy: Float = Float(endTouch!.y - (startTouch?.y)!)
        let distance = sqrt(dx*dx + dy*dy)
        if (distance >= Float(ViewController.kMinDistance)) {
            let dt: Float = Float((touches.first?.timestamp)! - startTime!)
            if dt > Float(ViewController.kMinDuration) {
             speed = distance / dt
                if (speed! >= Float(ViewController.kMinSpeed) && speed! <= Float(ViewController.kMaxSpeed)) {
                    isSwipe = true
                }
            }
        }

        if (basketPlaced && holdingBasketball && !thrownBasketball && isSwipe) {
            var power = ((-1/350) * distance) + 1.6428571
            print(distance, power)
            if power < 0.5 { power = 0.5 }
            if power > 1.5 { power = 1.5 }
            shootBasketball(power: power)
        }
        beingTouched = false
    }
    
    func shootBasketball(power: Float) {
        // Shoot the basketball in the direction of the camera
        let frame = self.sceneView.session.currentFrame
        let mat = SCNMatrix4((frame?.camera.transform)!)
        let dir = SCNVector3(-1 * mat.m31, -1 * (mat.m32 - 1), -1 * mat.m33)
        
        // Add the basketball's physicsbody
        basketball?.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: SCNPhysicsShape.init(geometry: SCNSphere(radius: 0.05)))
        basketball?.physicsBody?.categoryBitMask = ViewController.BALL_CATEGORY
        basketball?.physicsBody?.collisionBitMask = ViewController.SOLID_CATEGORY
        basketball?.physicsBody?.contactTestBitMask = ViewController.TOPPLANE_CATEGORY | ViewController.BOTPLANE_CATEGORY
        basketball!.physicsBody?.isAffectedByGravity = true
        basketball!.physicsBody?.mass = CGFloat(power)
        basketball!.physicsBody?.applyForce(dir, asImpulse: true)
        
        holdingBasketball = false
        thrownBasketball = true
        
        // Delete the basketball 3 seconds after shooting it
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (Timer) in
            self.deleteBasketball = true
        })
    }

    func holdBasketball() {
        // Create a basketball in front of the camera
        basketball = SCNScene(named: "art.scnassets/basketball.dae")?.rootNode.childNode(withName: "Basketball", recursively: true)
        basketball?.position = SCNVector3(0, -0.1, -0.5)
        sceneView.pointOfView?.addChildNode(basketball!)
        holdingBasketball = true
    }
    
    // Update function, called every (timeInterval)
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // First delete the basketball if necessary
        if deleteBasketball {
            basketScored = false
            basketball = nil
            thrownBasketball = false
            passedThroughTopPlane = false
            basketball?.removeFromParentNode()
            holdBasketball()
            deleteBasketball = false
        }
        
        if !basketPlaced {
            // Make nonplaced hoop 2 metres in front of camera
            let camDistance = getSceneSpacePosition(inFrontOf: sceneView.pointOfView!, atDistance: 1.5)
            hoopNode?.position = SCNVector3(camDistance.x, (sceneView.pointOfView?.position.y)!, camDistance.z)
            
            // Make nonplaced hoop facing the camera
            guard let camOrientation = sceneView.session.currentFrame?.camera.eulerAngles else { return }
            let hoopOrientation = SCNVector3Make((hoopNode?.eulerAngles.x)!, camOrientation.y, (hoopNode?.eulerAngles.z)!)
            hoopNode?.eulerAngles = hoopOrientation
        } else if basketPlaced {
            if (!holdingBasketball && !thrownBasketball) {
                holdBasketball()
            }
            if (holdingBasketball) {
                // Update label to show distance
                let displayText = SCNText.init(string: (NSString(format: "%.2f", getDistanceBetween(firstNode: basketball!, secondNode: hoopNode!)) as String) + "m", extrusionDepth: 0)
                displayText.font = UIFont(name: "AvenirNext-Medium", size: 60)
                let textcolor = SCNMaterial()
                textcolor.diffuse.contents = UIColor.white
                displayText.materials = [textcolor]
                
                let textnode = hoopNode?.childNode(withName: "distancenode", recursively: true)!.childNode(withName: "distancetext", recursively: true)!
                textnode?.geometry = displayText
                Nodes.center(node: textnode!)
            }
        }
    }
    
    // Create horizontal plane nodes
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let planeNode = SCNNode()
        Nodes.makeFloorPlane(node: planeNode, anchor: anchor)
        node.addChildNode(planeNode)
    }
    
    // Update horizontal plane nodes
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeNode = node.childNodes.first else {return}
        
        Nodes.makeFloorPlane(node: planeNode, anchor: anchor)
    }
    
    // Get position in front of a node at a certain distance
    func getSceneSpacePosition(inFrontOf node: SCNNode, atDistance distance: Float) -> SCNVector3 {
        let localPosition = SCNVector3(0, 0, -distance)
        let scenePosition = node.convertPosition(localPosition, to: sceneView.scene.rootNode)
        return scenePosition
    }
    
    // Get the distance between two nodes
    func getDistanceBetween(firstNode: SCNNode, secondNode: SCNNode) -> Float {
        let horizontalDistance = sqrt(pow((firstNode.worldPosition.x - secondNode.worldPosition.x), 2) + pow((firstNode.worldPosition.y - secondNode.worldPosition.y), 2))
        let actualDistance = sqrt(pow(horizontalDistance, 2) + pow((firstNode.worldPosition.z - secondNode.worldPosition.z), 2))
        return actualDistance
    }
 
    // MARK: Collision detection methods
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.name == "top plane" {
            passedThroughTopPlane = false
        } else if contact.nodeA.name == "bottom plane" && passedThroughTopPlane == true && basketScored == false {
            basketScored = true
            
            hoopNode?.addChildNode(Nodes.getBasketMadeNode())
            hoopNode?.childNode(withName: "winner", recursively: true)?.runAction(Animations.fadeOutAndIn(), completionHandler: {
                self.hoopNode?.childNode(withName: "winner", recursively: true)?.removeFromParentNode()
            })
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if(contact.nodeA.name == "top plane") {
            passedThroughTopPlane = true
        }
    }
    
    // MARK: UIViewController methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
