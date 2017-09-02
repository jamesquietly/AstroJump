//
//  PresetSongScene.swift
//  AstroJump
//
//  Created by James Ly on 5/15/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class PresetSongScene: SKScene, SelectProtocol {
    
    var songTableView = SongTableView()
    var songNameNode = SKLabelNode(text: "song name")
    var startNode = SKLabelNode(text: "Start Game")
    var backNode = SKLabelNode(text: "< Back")
    
    func fontSetup(label: SKLabelNode, posX: CGFloat, posY: CGFloat) {
        label.position = CGPoint(x: self.frame.width/2 + posX, y: self.frame.height/2 + posY)
        label.fontColor = .blue
        label.fontSize = 100
        label.fontName = "Helvetica-Bold"
    }
    
    override func didMove(to view: SKView) {
        songTableView.selectProtocol = self
        songTableView.songArray.append(Song(title: "Neon Rainbow", artist: "Rameses B", videoId: "1"))
        songTableView.songArray.append(Song(title: "Rush Over Me", artist: "Illenium", videoId: "2"))
        songTableView.songArray.append(Song(title: "Fire", artist: "3LAU", videoId: "2"))
        songTableView.songArray.append(Song(title: "Catch Fire (Anki Remix)", artist: "Hicari", videoId: "2"))
        
        songTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        songTableView.frame = CGRect(x: view.bounds.width/2 - 200, y: view.bounds.height/2 - 200, width: 400, height: 400)
        songTableView.backgroundColor = .clear
        songTableView.layer.borderColor = UIColor.black.cgColor
        songTableView.layer.borderWidth = 2.0
        self.view?.addSubview(songTableView)
        self.songTableView.reloadData()
        
        fontSetup(label: songNameNode, posX: 0, posY: -self.frame.height/2.5)
        songNameNode.name = "songNameLabel"
        addChild(songNameNode)
        
        fontSetup(label: startNode, posX: 0, posY: -self.frame.height/2.2)
        startNode.name = "startLabel"
        addChild(startNode)
        
        fontSetup(label: backNode, posX: -self.frame.width/5, posY: self.frame.height/3)
        backNode.name = "backLabel"
        addChild(backNode)
    }
    
    func didSelectRow(row: IndexPath, data: Song) {
        print("row: \(row.row) and string: \(data.title)")
        songNameNode.text = data.title
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let rightTransition = SKTransition.push(with: .right, duration: 1.0)
        let leftTransition = SKTransition.push(with: .left, duration: 1.0)
        
        let location = touches.first?.location(in: self)
        
        if (backNode.contains(location!)) {
            if let scene = SongModeScene(fileNamed: "SongModeScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                songTableView.removeFromSuperview()
                self.view?.presentScene(scene, transition: rightTransition)
            }
        }
        else if (startNode.contains(location!)) {
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                songTableView.removeFromSuperview()
                scene.selectedSongName = songNameNode.text
                self.view?.presentScene(scene, transition: leftTransition)
            }
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        //songNameNode?.text = songTableView.currentSong
    }
}
