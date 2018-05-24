//
//  ViewController.swift
//  AR Ruler
//
//  Created by Evan Kirkiles on 5/24/18.
//  Copyright © 2018 Evan Kirkiles. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

@available(iOS 11.3, *)
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    private var currPlaneId: Int = 0
    
    var drawingLine = false
    
    var originNode: SCNNode?
    var startNode: SCNNode?
    var endNode: SCNNode?
    var lineNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        /*
        // Initialize the placement node
        originNode = Nodes.getNode()
        originNode?.geometry?.firstMaterial?.transparency = 0.5
        originNode?.position = SCNVector3(0, 0, -0.3048)
        sceneView.pointOfView?.addChildNode(originNode!)
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Create node on the detected plane
        startNode = Nodes.getNode()
        
        // Get coordinates of hit test
        guard let touch = touches.first else { return }
        let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitFeature = results.last else { return }
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41,
                                         hitTransform.m42,
                                         hitTransform.m43)
        startNode?.position = hitPosition
        sceneView.scene.rootNode.addChildNode(startNode!)
        drawingLine = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Create node directly in front of camera as ending node
        endNode = Nodes.getNode()
        
        // Get coordinates of hit test
        guard let touch = touches.first else { return }
        let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitFeature = results.last else { return }
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41,
                                         hitTransform.m42,
                                         hitTransform.m43)
        
        endNode?.position = (hitPosition)
        sceneView.scene.rootNode.addChildNode(endNode!)
        
        drawingLine = false
        
        lineNode?.removeFromParentNode()
        
        let finishedLine = drawLineBetween(pos1: (startNode?.position)!, toPos2: (endNode?.position)!)
        let distanceNode = Nodes.getDistanceDisplayNode()
        distanceNode.worldPosition = getMidpoint(firstNode: startNode!, secondNode: endNode!)
        finishedLine.addChildNode(distanceNode)
        
        let displayText = SCNText.init(string: (NSString(format: "%.2f", getDistanceBetween(firstNode: startNode!, secondNode: endNode!)) as String) + "m", extrusionDepth: 0)
        displayText.font = UIFont(name: "AvenirNext-Medium", size: 20)
        let textcolor = SCNMaterial()
        textcolor.diffuse.contents = UIColor.white
        displayText.materials = [textcolor]
        
        let textnode = finishedLine.childNode(withName: "distancenode", recursively: true)!.childNode(withName: "distancetext", recursively: true)!
        textnode.geometry = displayText
        Nodes.center(node: textnode)
        
        sceneView.scene.rootNode.addChildNode(finishedLine)
    }
    
    // Draw line between two vector positions
    func drawLineBetween(pos1: SCNVector3, toPos2: SCNVector3) -> SCNNode {
        let line = lineFrom(vector: pos1, toVector: toPos2)
        let lineInBetween1 = SCNNode(geometry: line)
        return lineInBetween1
    }
    // Get line geometry between two vectors
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0,1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
    // Get the distance between two nodes
    func getDistanceBetween(firstNode: SCNNode, secondNode: SCNNode) -> Float {
        let horizontalDistance = sqrt(pow((firstNode.worldPosition.x - secondNode.worldPosition.x), 2) + pow((firstNode.worldPosition.y - secondNode.worldPosition.y), 2))
        let actualDistance = sqrt(pow(horizontalDistance, 2) + pow((firstNode.worldPosition.z - secondNode.worldPosition.z), 2))
        return actualDistance
    }
    // Get midpoint between two nodes
    func getMidpoint(firstNode: SCNNode, secondNode: SCNNode) -> SCNVector3 {
        let x = (firstNode.worldPosition.x + secondNode.worldPosition.x)/2
        let y = (firstNode.worldPosition.y + secondNode.worldPosition.y)/2
        let z = (firstNode.worldPosition.z + secondNode.worldPosition.z)/2
        return SCNVector3(x, y, z)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (drawingLine) {
            // REMOVE THIS LINE TO MAKE COOL ART
            lineNode?.removeFromParentNode()
            
            // Get coordinates of hit test
            guard let touch = touches.first else { return }
            let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
            guard let hitFeature = results.last else { return }
            let hitTransform = SCNMatrix4(hitFeature.worldTransform)
            let hitPosition = SCNVector3Make(hitTransform.m41,
                                             hitTransform.m42,
                                             hitTransform.m43)
            
            lineNode = drawLineBetween(pos1: (startNode?.position)!, toPos2: (hitPosition))
            sceneView.scene.rootNode.addChildNode(lineNode!)
        }
    }
    
    // Get position in front of a node at a certain distance
    func getSceneSpacePosition(inFrontOf node: SCNNode, atDistance distance: Float) -> SCNVector3 {
        let localPosition = SCNVector3(0, 0, -distance)
        let scenePosition = node.convertPosition(localPosition, to: sceneView.scene.rootNode)
        return scenePosition
    }
    
    // MARK: ARPlaneAnchor horizontal and vertical plane detection
    // https://github.com/jaxony/ar-scene-plane-geometry-demo
    
    // Runs when new ARAnchor is detected and added to scene
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Only care about detected planes
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = createPlaneNode(planeAnchor: planeAnchor)
        sceneView.scene.rootNode.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // only care about detected planes (i.e. `ARPlaneAnchor`s)
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print("Updating plane anchor")
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let planeNode = createPlaneNode(planeAnchor: planeAnchor)
        node.addChildNode(planeNode)
        
        //        let planeNode = node.childNode(withName: node.name!, recursively: false)
        //        let g = planeNode?.geometry as? ARSCNPlaneGeometry
        //        g?.update(from: planeAnchor.geometry)
        //        planeNode?.geometry = g
        //        node.addChildNode(planeNode!)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        print("Removing plane anchor")
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    func createPlaneNode(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let scenePlaneGeometry = ARSCNPlaneGeometry(device: metalDevice!)
        scenePlaneGeometry?.update(from: planeAnchor.geometry)
        let planeNode = SCNNode(geometry: scenePlaneGeometry)
        planeNode.name = "\(currPlaneId)"
        planeNode.opacity = 0.05
        if planeAnchor.alignment == .horizontal {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        } else {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        }
        currPlaneId += 1
        return planeNode
    }
    
    // DEFAULT FUNCTIONS
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
