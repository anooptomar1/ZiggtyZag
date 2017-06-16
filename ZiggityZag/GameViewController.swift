//
//  GameViewController.swift
//  ZiggityZag
//
//  Created by Árthur Ken Aramaki Mota on 16/06/17.
//  Copyright © 2017 Árthur Ken Aramaki Mota. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    let scene = SCNScene()
    let cameraNode = SCNNode()
    
    var person = SCNNode()
    
    let firstBox = SCNNode()
    
    var goingLeft = Bool()
    
    var tempBox = SCNNode()
    
    var prevBoxNumber = Int()
    
    var boxNumber = Int()
    
    override func viewDidLoad() {
        self.createScene()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        let deleteBox = self.scene.rootNode.childNode(withName: "\(prevBoxNumber)", recursively: true)
        
        if (deleteBox?.position.x)! > person.position.x + 1 || (deleteBox?.position.z)! > person.position.z + 1 {
            
            prevBoxNumber += 1
            deleteBox?.removeFromParentNode()
        
            createBox()
            
        }
        
        
    }
    
    
    func createBox() {
        tempBox = SCNNode(geometry: firstBox.geometry)
        let prevBox = scene.rootNode.childNode(withName: "\(boxNumber)", recursively: true)
        
        boxNumber += 1
        tempBox.name = "\(boxNumber)"
        
        let randomNumber = arc4random() % 2
        
        switch randomNumber {
        case 0:
            tempBox.position = SCNVector3Make((prevBox?.position.x)! - firstBox.scale.x, (prevBox?.position.y)!, (prevBox?.position.z)!)
            break
        case 1:
            tempBox.position = SCNVector3Make((prevBox?.position.x)!, (prevBox?.position.y)!, (prevBox?.position.z)! - firstBox.scale.z)
            break
        default:
            break
        }
        
        self.scene.rootNode.addChildNode(tempBox)
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if goingLeft == false {
            person.removeAllActions()
            person.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-100, 0, 0), duration: 20)))
            goingLeft = true
        } else {
            person.removeAllActions()
            person.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(0, 0, -100), duration: 20)))
            goingLeft = false
            
        }
        
        
    }
    
    
    func createScene() {
        
        boxNumber = 0
        prevBoxNumber = 0
        
        self.view.backgroundColor = UIColor.white
        
        let sceneView = self.view as! SCNView
        sceneView.delegate = self
        sceneView.scene = scene
        
        // Create Person
        let personGeo = SCNSphere(radius: 0.2)
        person = SCNNode(geometry: personGeo)
        let personMat = SCNMaterial()
        personMat.diffuse.contents = UIColor.red
        personGeo.materials = [personMat]
        person.position = SCNVector3Make(0, 1.1, 0)
        scene.rootNode.addChildNode(person)
        
        
        // Create Camera
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 3
        cameraNode.position = SCNVector3Make(20, 20, 20)
        cameraNode.eulerAngles = SCNVector3Make(-45, 45, 0)
        let constraint = SCNLookAtConstraint(target: person)
        constraint.isGimbalLockEnabled = true
        self.cameraNode.constraints = [constraint]
        scene.rootNode.addChildNode(cameraNode)
        person.addChildNode(cameraNode)

        
        // Cretae Box
        let firstBoxGeo = SCNBox(width: 1, height: 1.5, length: 1, chamferRadius: 0)
        firstBox.geometry = firstBoxGeo
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.8, blue: 0.9, alpha: 1.0)
        firstBoxGeo.materials = [boxMaterial]
        firstBox.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(firstBox)
        firstBox.name = "\(boxNumber)"
        
        for _ in 0...6 {
            createBox()
        }
        
        // Create Light
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = SCNLight.LightType.directional
        light.eulerAngles = SCNVector3Make(-45, 45, 0)
        scene.rootNode.addChildNode(light)
        
        let light2 = SCNNode()
        light2.light = SCNLight()
        light2.light?.type = SCNLight.LightType.directional
        light2.eulerAngles = SCNVector3Make(45, 45, 0)
        scene.rootNode.addChildNode(light2)
        
        
    }

}
