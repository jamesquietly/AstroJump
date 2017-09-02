//
//  SongModeScene.swift
//  AstroJump
//
//  Created by James Ly on 5/14/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class SongModeScene: SKScene {
    
    var backNode = SKLabelNode(text: "< Back")
    
    func fontSetup(label: SKLabelNode, posX: CGFloat, posY: CGFloat) {
        label.position = CGPoint(x: self.frame.width/2 + posX, y: self.frame.height/2 + posY)
        label.fontColor = .blue
        label.fontSize = 100
        label.fontName = "Helvetica-Bold"
    }
    
    override func didMove(to view: SKView) {
        fontSetup(label: backNode, posX: -self.frame.width/5, posY: self.frame.height/3)
        addChild(backNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let rightTransition = SKTransition.push(with: .right, duration: 1.0)
        let leftTransition = SKTransition.push(with: .left, duration: 1.0)
        
        let location = touches.first?.location(in: self)
        let presetNode = childNode(withName: "presetLabel")
        let youtubeNode = childNode(withName: "youtubeLabel")
        
        if (backNode.contains(location!)) {
            if let scene = MainMenuScene(fileNamed: "MainMenuScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                self.view?.presentScene(scene, transition: rightTransition)
            }
        }
        else if (presetNode?.contains(location!))! {
            if let scene = PresetSongScene(fileNamed: "PresetSongScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                self.view?.presentScene(scene, transition: leftTransition)
            }
        }
        else if (youtubeNode?.contains(location!))! {
            if let scene = YoutubeScene(fileNamed: "YoutubeScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                self.view?.presentScene(scene, transition: leftTransition)
            }
        }
        
        
    }
}
