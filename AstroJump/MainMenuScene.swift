//
//  MainMenuScene.swift
//  AstroJump
//
//  Created by James Ly on 5/14/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class MainMenuScene: SKScene, GKGameCenterControllerDelegate {
    //var signInNode: SKLabelNode!
    
    func fontSetup(text: String, posX: CGFloat, posY: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.position = CGPoint(x: self.frame.width/2 + posX, y: self.frame.height/2 + posY)
        label.fontColor = .blue
        label.fontSize = 100
        label.fontName = "Helvetica-Bold"
        return label
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    override func didMove(to view: SKView) {
        let nameLabel = fontSetup(text: "Astro Jump", posX: 0, posY: self.frame.height/10)
        nameLabel.name = "nameLabel"
        addChild(nameLabel)
        
        let startLabel = fontSetup(text: "Play Game", posX: 0, posY: 0)
        startLabel.name = "startLabel"
        addChild(startLabel)
        
        let leaderboardLabel = fontSetup(text: "View Leaderboard", posX: 0, posY: -self.frame.height/10)
        leaderboardLabel.name = "leaderboardLabel"
        addChild(leaderboardLabel)
        
        /*let signInLabel = fontSetup(text: "Sign In", posX: 0, posY: -self.frame.height/5)
        signInLabel.name = "signInLabel"
        signInNode = signInLabel
        addChild(signInLabel) */
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let transition = SKTransition.push(with: .left, duration: 1.0)
 
        let location = touches.first?.location(in: self)
        let startNode = childNode(withName: "startLabel")
        let leaderboardNode = childNode(withName: "leaderboardLabel")

        if (startNode?.contains(location!))! {
            if let scene = SongModeScene(fileNamed: "SongModeScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                self.view?.presentScene(scene, transition: transition)
            }
        }
        else if (leaderboardNode?.contains(location!))! {
            if let scene = LeaderboardScene(fileNamed: "LeaderboardScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                /*let gcVC = GKGameCenterViewController()
                gcVC.gameCenterDelegate = self
                gcVC.viewState = .leaderboards
                gcVC.leaderboardIdentifier = "com.score.AstroJump"
                let rootVC = self.view?.window?.rootViewController
                rootVC?.present(gcVC, animated: true, completion: nil) */
                // Present the scene
                self.view?.presentScene(scene, transition: transition)
            }
        }

            

    }
    
    

    
}
