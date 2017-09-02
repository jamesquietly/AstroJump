//
//  LeaderboardScene.swift
//  AstroJump
//
//  Created by James Ly on 5/14/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import Firebase

class LeaderboardScene: SKScene {
    var leaderboardRoot: DatabaseReference?
    var scoreTableView = ScoreTV()
    
    func fontSetup(text: String, posX: CGFloat, posY: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.position = CGPoint(x: self.frame.width/2 + posX, y: self.frame.height/2 + posY)
        label.fontColor = .blue
        label.fontSize = 100
        label.fontName = "Helvetica-Bold"
        return label
    }
    
    override func didMove(to view: SKView) {
        let backLabel = fontSetup(text: "< Back", posX: -self.frame.width/5, posY: self.frame.height/3)
        backLabel.name = "backLabel"
        addChild(backLabel)
        
        let leaderboardLabel = fontSetup(text: "Leaderboard", posX: -self.frame.width/6, posY: self.frame.height/5)
        leaderboardLabel.name = "leaderboardLabel"
        addChild(leaderboardLabel)
        
        leaderboardRoot = Database.database().reference(withPath: "Leaderboard")
        
        scoreTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        scoreTableView.frame = CGRect(x: view.frame.width/100, y: view.frame.height/3, width: view.frame.width/1.1, height: view.frame.height/2)
        scoreTableView.backgroundColor = .clear
        scoreTableView.layer.borderColor = UIColor.black.cgColor
        scoreTableView.layer.borderWidth = 2.0
        self.view?.addSubview(scoreTableView)
        setRetrieveCallback()
        
    }
    
    func setRetrieveCallback() {
        leaderboardRoot?.queryOrdered(byChild: "Leaderboard").observe(.value, with:
            { snapshot in
            var newScores = [Score]()
            for item in snapshot.children {
                newScores.append(Score(snapshot: item as! DataSnapshot))
            }
            self.scoreTableView.scoreArray = newScores
            self.scoreTableView.reloadData()
            })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let transition = SKTransition.push(with: .right, duration: 1.0)
        
        let location = touches.first?.location(in: self)
        let backNode = childNode(withName: "backLabel")
        
        if (backNode?.contains(location!))! {
            scoreTableView.removeFromSuperview()
            if let scene = MainMenuScene(fileNamed: "MainMenuScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                // Present the scene
                self.view?.presentScene(scene, transition: transition)
            }
        }
        
        
    }
}
