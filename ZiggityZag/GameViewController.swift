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

class GameViewController: UIViewController {

    let scene = SCNScene()
    let cameraNode = SCNNode()
    
    let firstBox = SCNNode()
    
    override func viewDidLoad() {
        self.createScene()
        
        
    }
    
    func createScene() {
        
        let sceneView = self.view as! SCNView
        
        sceneView.scene = scene
        
        // Create Camera
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 3
        cameraNode.position = SCNVector3Make(20, 20, 20)
        cameraNode.eulerAngles = SCNVector3Make(-45, 45, 0)
        let constraint = SCNLookAtConstraint(target: firstBox)
        constraint.isGimbalLockEnabled = true
        self.cameraNode.constraints = [constraint]
        scene.rootNode.addChildNode(cameraNode)

        
        // Cretae Box
        let firstBoxGeo = SCNBox(width: 1, height: 1.5, length: 1, chamferRadius: 0)
        firstBox.geometry = firstBoxGeo
        firstBox.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(firstBox)
        
        // Create Light
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = SCNLight.LightType.directional
        light.eulerAngles = SCNVector3Make(-45, 45, 0)
        scene.rootNode.addChildNode(light)
        
        
        
    }

}
