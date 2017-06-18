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
import GameKit

struct bodyNames {
    static let Person = 0x1 << 1
    static let Coin = 0x1 << 2
}

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, GKGameCenterControllerDelegate {

    let scene = SCNScene()
    
    let cameraNode = SCNNode()
    
    var person = SCNNode()
    
    let firstBox = SCNNode()
    
    var goingLeft = Bool()
    
    var tempBox = SCNNode()
    
    var prevBoxNumber = Int()
    
    var boxNumber = Int()
    
    var firstOne = Bool()
    
    var score = Int()
    var highScore = Int()
    
    var dead = Bool()
    
    var scoreLbl = UILabel()
    var highscoreLbl = UILabel()
    
    var gameButton = UIButton()
    
    override func viewDidLoad() {
        self.createScene()
        
        authenticatePlayer()
        
        scoreLbl = UILabel(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + self.view.frame.height / 2.5, width: self.view.frame.width, height: 100))
        scoreLbl.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - self.view.frame.height / 2.5)
        
        
        scoreLbl.textAlignment = .center
        scoreLbl.text = "Score: \(score)"
        scoreLbl.textColor = UIColor.darkGray
        self.view.addSubview(scoreLbl)
        
        highscoreLbl = UILabel(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + self.view.frame.height / 2.5, width: self.view.frame.width, height: 100))
        highscoreLbl.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + self.view.frame.height / 2.5)
        
        highscoreLbl.textAlignment = .center
        highscoreLbl.text = "Highscore: \(highScore)"
        highscoreLbl.textColor = UIColor.darkGray
        self.view.addSubview(highscoreLbl)
        
        scene.physicsWorld.contactDelegate = self
        
        
        gameButton = UIButton(type: .custom)
        gameButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        gameButton.center = CGPoint(x: self.view.frame.width - 40, y: 60)
        gameButton.setImage(UIImage(named: "gamecenter"), for: .normal)
        gameButton.addTarget(self, action: ("showLeaderboard"), for: .touchUpInside)
        self.view.addSubview(gameButton)
        
        
    }
    
    func updateLabel() {
        scoreLbl.text = "Score: \(score)"
        highscoreLbl.text = "Highscore: \(highScore)"
    }
    
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == bodyNames.Coin && nodeB.physicsBody?.categoryBitMask == bodyNames.Person {
            
            nodeA.removeFromParentNode()
            addScore()
            
        } else if nodeA.physicsBody?.categoryBitMask == bodyNames.Person && nodeB.physicsBody?.categoryBitMask == bodyNames.Coin {
            
            nodeB.removeFromParentNode()
            addScore()
            
        }
    }
    
    func addScore() {
        score += 1
    
        self.performSelector(onMainThread: Selector("updateLabel"), with: nil, waitUntilDone: false)
        
    
        if score > highScore {
            
            highScore = score
            
            let scoreDefault = UserDefaults.standard
            scoreDefault.set(highScore, forKey: "highscore")
            print(highScore)
            
        }
        
    }
    
    
    
    
    // fade in
    
    func fadeIn(node: SCNNode){
        node.opacity = 0
        node.runAction(SCNAction.fadeIn(duration: 0.5))
    }
    
    // fade out
    
    func fadeOut(node: SCNNode) {
        let move = SCNAction.move(by: SCNVector3Make(node.position.x, node.position.y - 2, node.position.z), duration: 0.5)
        node.runAction(move)
        node.runAction(SCNAction.fadeOut(duration: 0.5))
        
        
    }
    
    
    func createCoin(box: SCNNode){
        
        scene.physicsWorld.gravity = SCNVector3Make(0, 0, 0)
        
        let spin = SCNAction.rotate(by: CGFloat(Double.pi * 2), around: SCNVector3Make(0, 0.5, 0), duration: 0.5)
        let randomNumber = arc4random() % 8
        if randomNumber == 3 {
            let coinScene = SCNScene(named: "Coin.dae")
            let coin = coinScene?.rootNode.childNode(withName: "Coin", recursively: true)
            coin?.position = SCNVector3Make(box.position.x, box.position.y + 1, box.position.z)
            coin?.scale = SCNVector3Make(0.2, 0.2, 0.2)
            
            coin?.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: SCNPhysicsShape(node: coin!, options: nil))
            coin?.physicsBody?.categoryBitMask = bodyNames.Coin
            coin?.physicsBody?.contactTestBitMask = bodyNames.Person
            coin?.physicsBody?.collisionBitMask = bodyNames.Person
            coin?.physicsBody?.isAffectedByGravity = false
            
            scene.rootNode.addChildNode(coin!)
            
            fadeIn(node: coin!)
            
            coin?.runAction(SCNAction.repeatForever(spin))
        }
        
        
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if dead == false {
            
            let deleteBox = self.scene.rootNode.childNode(withName: "\(prevBoxNumber)", recursively: true)
            
            let currentBox = self.scene.rootNode.childNode(withName: "\(prevBoxNumber + 1)", recursively: true)
            
            if (deleteBox?.position.x)! > person.position.x + 1 || (deleteBox?.position.z)! > person.position.z + 1 {
                
                //fadeOut(node: deleteBox!)
                
                prevBoxNumber += 1
                //deleteBox?.removeFromParentNode()
                
                createBox()
                
            }
            
            if person.position.x > (currentBox?.position.x)! - 0.5 && person.position.x < (currentBox?.position.x)! + 0.5 || person.position.z > (currentBox?.position.z)! - 0.5 && person.position.z < (currentBox?.position.z)! + 0.5 {
                
                // On platform
                
                
            } else {
                
                die()
                dead = true
                
            }
        }
    }
    
    func die() {
        
        person.runAction(SCNAction.move(to: SCNVector3Make(person.position.x, person.position.y - 10, person.position.z), duration: 1.0))
        
        let wait = SCNAction.wait(duration: 0.5)
        
        let sequence = SCNAction.sequence([wait, SCNAction.run({ (node) in
            
            self.scene.rootNode.enumerateChildNodes({ (node, stop) in
                
                node.removeFromParentNode()
                
            })
            
        }), SCNAction.run({ (node) in
            
            self.createScene()
            
        })])
        
        person.runAction(sequence)
    }
    
    
    func createBox() {
        tempBox = SCNNode(geometry: firstBox.geometry)
        
        fadeIn(node: tempBox)
        
        let prevBox = scene.rootNode.childNode(withName: "\(boxNumber)", recursively: true)
        
        boxNumber += 1
        tempBox.name = "\(boxNumber)"
        
        let randomNumber = arc4random() % 2
        
        switch randomNumber {
        case 0:
            tempBox.position = SCNVector3Make((prevBox?.position.x)! - firstBox.scale.x, (prevBox?.position.y)!, (prevBox?.position.z)!)
            
            if firstOne == true {
                firstOne = false
                goingLeft = false
            }
            
            break
        case 1:
            tempBox.position = SCNVector3Make((prevBox?.position.x)!, (prevBox?.position.y)!, (prevBox?.position.z)! - firstBox.scale.z)
            
            if firstOne == true {
                firstOne = false
                goingLeft = true
            }
            
            break
        default:
            break
        }
        
        self.scene.rootNode.addChildNode(tempBox)
        createCoin(box: tempBox)
        //fadeIn(node: tempBox)
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dead == true {
            return
        }
        
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
    
        score = 0
        
        let scoreDefault = UserDefaults.standard
        
        if scoreDefault.integer(forKey: "highscore") != 0 {
            highScore = scoreDefault.integer(forKey: "highscore")
        } else {
            
            highScore = 0
            
        }
        
        print(highScore)
        
        
        boxNumber = 0
        prevBoxNumber = 0
        firstOne = true
        dead = false
    
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
        
        person.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: SCNPhysicsShape(node: person, options: nil))
        person.physicsBody?.categoryBitMask = bodyNames.Person
        person.physicsBody?.collisionBitMask = bodyNames.Coin
        person.physicsBody?.contactTestBitMask = bodyNames.Coin
        person.physicsBody?.isAffectedByGravity = false
        
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
    
    func authenticatePlayer(){
        
        let localPlayer = GKLocalPlayer()
        
        localPlayer.authenticateHandler = {
            (viewController, error) in
            
            if viewController != nil {
                self.present(viewController!, animated: true, completion: nil)
            } else {
                print("logged in")
            }
            
        }
        
    }
    
    func saveHighscore(score: Int) {
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "zag.001")
            
            scoreReporter.value = Int64(score)
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: nil)
            
        }
        
    }
    
    func showLeaderboard() {
        
        saveHighscore(score: highScore)
        
        let gc = GKGameCenterViewController()
        
        gc.gameCenterDelegate = self
        
        self.present(gc, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        
        gameCenterViewController.dismiss(animated: true, completion: nil)
        
    }
    

}
