//
//  ViewController.swift
//  STry1
//
//  Created by elaine on 2020/4/11.
//  Copyright © 2020 yuri. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GLKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var switchDraw: UISwitch!
    @IBOutlet var clearButton: UIButton!
  
    @IBOutlet var Xslider: UISlider!
    @IBOutlet var Yslider: UISlider!
    @IBOutlet var Zslider: UISlider!
   
    
    
    var Xchange :Float = 0.0
    var Ychange :Float = 0.0
    var Zchange :Float = 0.0
    
    @IBAction func XChanged(_ sender: UISlider) {
        Xchange = sender.value
    }
    
    @IBAction func YChanged(_ sender: UISlider) {
        Ychange = sender.value
    }
    
    
    @IBAction func ZChanged(_ sender: UISlider) {
        Zchange = sender.value
    }
    
    
    //rotation angle define
    //In this example, we’ll be rotating the //virtual plane around its z-axis
    var newAngleZ : Float  = 0.0
    var currentAngleZ : Float  = 0.0
    
    let showLight=SCNNode()
    
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    
    @IBAction func resetButton(_ sender: UIButton) {
        sceneView.session.pause()
        
        sceneView.scene.rootNode.enumerateChildNodes({
            (node,_) in
                if node.name=="shape"{
                    node.removeFromParentNode()
            }
        })
        
        sceneView.session.run(configuration, options:[.resetTracking,.removeExistingAnchors])
       
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        showShape()
       }
       
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Detect the plane
         configuration.planeDetection = .horizontal
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Show feature points
        sceneView.debugOptions=[ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        
       
        //Detecting touch gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapResponse))
        sceneView.addGestureRecognizer(tapGesture)
        
        //Allow the user to swipe across a virtual object
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRightGesture.direction = .right
        sceneView.addGestureRecognizer(swipeRightGesture)
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeftGesture.direction = .left
        sceneView.addGestureRecognizer(swipeLeftGesture)
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUpGesture.direction = .up
        sceneView.addGestureRecognizer(swipeUpGesture)
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDownGesture.direction = .down
        sceneView.addGestureRecognizer(swipeDownGesture)
        
        showShape()
        
    }
    
    //Function displayTexture to show //the plane
           func displayTexture(anchor: ARPlaneAnchor)->SCNNode{
               let planeNode = SCNNode()
               planeNode.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
               planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "texture.png")
               planeNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
               
               let ninetyDegrees = GLKMathDegreesToRadians(90)
               planeNode.eulerAngles = SCNVector3(ninetyDegrees,0,0)
            planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
               planeNode.geometry?.firstMaterial?.isDoubleSided = true
               
               return planeNode
               
           }
           
          
           
           
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showShape()
        lightOn()
       
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    //This information from the UITapGestureRecognizer can tell us whether the user tapped on a //virtual object or not
    @objc func handleTap(sender: UITapGestureRecognizer){
        print("tap detected")
        
        //First, we need to get the area or view of the tapped portion of the screen like this:
        let areaTapped = sender.view as! SCNView
        //Once we know the area tapped, we need to get the actual coordinates
       // of that area like this:
        let tappedCoordinates = sender.location(in: areaTapped)
        //Now we need to determine if there is any virtual objects in the tapped area using a //function called hitTest. This hitTest function does the hard work of identifying //virtual objects within a specific set of coordinates:
        let hitTest = areaTapped.hitTest(tappedCoordinates)
        
        if hitTest.isEmpty{
            print("Nothing")
        }else{
            //If the hitTest function identifies a virtual object, it stores this information in //an array, so we need to retrieve the first item from this array:
            let results = hitTest.first!
            let name = results.node.name
            print(name ?? "background")
            
        }
    }
    
    //we’ll add each time the user taps the screen on a horizontal plane will be an orange pyramid
    func addObject(hitResult: ARHitTestResult){
        let objectNode = SCNNode()
        objectNode.geometry = SCNPyramid(width: 0.1, height: 0.2, length: 0.1)
        objectNode.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        
        //define the position of each pyramid
        //The x, y, and z positions are stored in the third column of this worldTransform matrix
        objectNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        objectNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        sceneView.scene.rootNode.addChildNode(objectNode)
    }
    
    @objc func tapResponse(sender: UITapGestureRecognizer){
        let scene = sender.view as! ARSCNView
        let tapLocation = sender.location(in: scene)
        let hitTest = scene.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if hitTest.isEmpty{
            print("no plane detected")
        }else{
            print("found a horizontal plane")
            guard let hitResult = hitTest.first else{return}
            //calls an addObject function //and sends the position of //where the user tapped
            addObject(hitResult: hitResult)
            
        }
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer){
        let areaSwiped = sender.view as! SCNView
        let tappedCoordinates = sender.location(in: areaSwiped)
        let hitTest = areaSwiped.hitTest(tappedCoordinates)
        
        if hitTest.isEmpty{
                   print("Nothing")
               }else{
                   //If the hitTest function identifies a virtual object, it stores this information in //an array, so we need to retrieve the first item from this array:
                   let results = hitTest.first!
                   let name = results.node.name
                   print(name ?? "background")
               }
        switch sender.direction{
        case .up:
            print("Up")
        case .down:
            print("Down")
        case .right:
            print("Right")
        case .left:
            print("Left")
        default:
            break
        }
        
    }
    
    
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //retrieve the iOS device camera’s location within the willRenderScene function
        guard let pov = sceneView.pointOfView else {return}
        //transform this information into a 4 by 4 matrix that contains
        //various information about the camera
        let transform = pov.transform
        //The third row of this 4 by 4 matrix contains the x, y, and z rotation of
        //the camera. To retrieve this information, we need to use this code.
        //This negative sign reverses the rotation information because without it, moving right //on the x-axis would be negative (instead of positive), moving up on the y-axis //would be negative (instead of positive), and moving back on the z-axis would be //negative (instead of positive).
        let rotation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        
        //retrieve the location of the camera from the fourth row of the 4 by 4 matrix
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        
        //Once we have the rotation and location of the camera, we need to add their x, y, and z //coordinates to get the position of the camera
        let currentPosition = SCNVector3(rotation.x + location.x, rotation.y + location.y, rotation.z + location.z)
        
        //We need additional code inside this renderer function to determine whether to show the //pointer or draw a line. Since this additional code will need to run at the same //time that the app displays the augmented reality view from the camera, we need to //use the DispatchQueue. This allows the app to show the camera and draw a line at //the same time.
        DispatchQueue.main.async {
            if self.switchDraw.isOn{
                let drawNode = SCNNode()
                drawNode.geometry = SCNSphere(radius: 0.01)
                drawNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
                drawNode.position = currentPosition
                self.sceneView.scene.rootNode.addChildNode(drawNode)
            }else{
                let point = SCNNode()
                point.name = "aiming point"
                point.geometry = SCNSphere(radius: 0.005)
                point.position = currentPosition
                point.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                self.sceneView.scene.rootNode.enumerateChildNodes({(node, _)in
                    if node.name == "aiming point"{
                        node.removeFromParentNode()
                    }
                })
                
                self.sceneView.scene.rootNode.addChildNode(point)
                
            }
            
            if self.clearButton.isHighlighted {
                self.sceneView.scene.rootNode.enumerateChildNodes(
                    {
                        (node, _)in
                        node.removeFromParentNode()
                    }
                )
            }
        }
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor : ARAnchor) {
        guard anchor is ARPlaneAnchor else{return}
       // Add a plane when detect a plane
             let planeNode = displayTexture(anchor: anchor as! ARPlaneAnchor)
        node.addChildNode(planeNode)
        print("plane detected")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else{return}
        
        // use the enumeratechildNodes loop //to constantly remove the old //horizontal plane, add the new //plane
        node.enumerateChildNodes{
            (childNode, _ ) in
            childNode.removeFromParentNode()
        }
        let planeNode = displayTexture(anchor: anchor as! ARPlaneAnchor)
        node.addChildNode(planeNode)
        
        print("updating floor anchor")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    func showShape(){
        let text=SCNText(string:"Hello",extrusionDepth: 1)
        
        let material=SCNMaterial()
        material.diffuse.contents=UIColor.orange
        text.materials=[material]
        
        let node=SCNNode()
        node.geometry=text
        node.position=SCNVector3(Xchange,Ychange,Zchange)
        node.scale=SCNVector3(0.01,0.01,0.01)
        node.name="shape"
        sceneView.scene.rootNode.addChildNode(node)
        
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        box.firstMaterial?.diffuse.contents=UIColor.green
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(-0.2,-0.2,0.1)
        node.addChildNode(boxNode)
    }
    
    func lightOn(){
        showLight.light=SCNLight()
        showLight.light?.type = .omni
        showLight.light?.color=UIColor(white: 0.6, alpha: 1.0)
        showLight.position=SCNVector3(0,0,0)
        sceneView.scene.rootNode.addChildNode(showLight)
        
    }
    @IBAction func temperatureChange(_ sender: UISlider) {
        showLight.light?.temperature = CGFloat(sender.value)
    }
    @IBAction func intensityChange(_ sender: UISlider) {
        showLight.light?.intensity = CGFloat(sender.value)
    }
    @IBAction func colorButton(_ sender: UIButton) {
        //colorMe.backgroundColor=sender.backgroundColor
        showLight.light?.color = sender.backgroundColor!
    }
    
    
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        
        //Touch gestures consist of three states:
       // • .began—Occurs when the app first detects a specific touch gesture
       // • .changed—Occurs while the touch gesture is still going on
       // • .ended—Occurs when the app detects that the touch gesture has stopped
        
        //For the pinch gesture, we just //care about when it’s changing //because as the user pinches in //or out, we want to scale the //size of the virtual plane in //the augmented reality view
        
        if sender.state == .changed{
            print("Pinch Gesture")
            let areaPinched = sender.view as? SCNView
            let location = sender.location(in: areaPinched)
            let hitTestResults = sceneView.hitTest(location, options: nil)
            //If the user touched the first //node in the augmented //reality view (the plane is //the only node), then we //can identify the hitTest //node with an arbitrary //name such as:
            if let hitTest = hitTestResults.first{
                let plane = hitTest.node
                let scaleX = Float(sender.scale)*plane.scale.x
                let scaleY = Float(sender.scale)*plane.scale.y
                let scaleZ = Float(sender.scale)*plane.scale.z
                plane.scale = SCNVector3(scaleX,scaleY,scaleZ)
                sender.scale = 1
            }
        }

    }
    
    
    
    @IBAction func rotationGesture(_ sender: UIRotationGestureRecognizer) {
        //write code that detects when the //rotation is happening //(.changed) and when the //rotation has stopped (.ended)
        if sender.state == .changed{
            let areaTouched = sender.view as? SCNView
            let location = sender.location(in: areaTouched)
            let hitTestResults = sceneView.hitTest(location, options: nil)
            if let hitTest = hitTestResults.first{
                let plane = hitTest.node
                //The negative sign is //necessary to //coordinate the //rotation gesture on //the screen with the //rotation of the //virtual plane in the //augmented reality view.
                newAngleZ = Float(-sender.rotation)
                newAngleZ += currentAngleZ
                plane.eulerAngles.z = newAngleZ
            }
        }else if sender.state == .ended{
            currentAngleZ = newAngleZ
        }
        
    }
    
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let areaPanned = sender.view as? SCNView
        let location = sender.location(in: areaPanned)
        let hitTestResults = areaPanned?.hitTest(location, options: nil)
        //To move a virtual object, we need //to move the parent node //because this will //automatically move any //attached nodes.
        if let hitTest = hitTestResults?.first{
            if let plane = hitTest.node.parent{
                if sender.state == .changed{
                    let translate = sender.translation(in: areaPanned)
                    //apply this translation //movement to the //virtual object //itself:
                    //Large values such as //10000 force the //movement to occur //more smoothly. //10000 is an //arbitrary value
                    
                    plane.localTranslate(by: SCNVector3(translate.x/10000,-translate.y/10000,0.0))
                }
            }
        }
        
    }
    
}
