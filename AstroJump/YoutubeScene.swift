//
//  YoutubeScene.swift
//  AstroJump
//
//  Created by James Ly on 5/15/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import youtube_ios_player_helper

class YoutubeScene: SKScene, SelectProtocol, YTPlayerViewDelegate {
    let apiUrl = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=50&q="
    let apiKey = "&type=video&key=AIzaSyBDEV5tUDWSuLPI6HWiIEgBmjsBGE8HJDI"
    let playerParam: [String: Any] = ["playsinline":1, "origin":"https://www.youtube.com"]
    
    var searchTextField: UITextField!
    var searchTerm: String = ""
    var songTableView = SongTableView()
    var webView: UIWebView!
    var ytPlayer: YTPlayerView!
    var startNode = SKLabelNode(text: "Start Game")
    var backNode = SKLabelNode(text: "< Back")
    var searchNode = SKLabelNode(text: "Search")
    
    func fontSetup(label: SKLabelNode, posX: CGFloat, posY: CGFloat) {
        label.position = CGPoint(x: self.frame.width/2 + posX, y: self.frame.height/2 + posY)
        label.fontColor = .blue
        label.fontSize = 100
        label.fontName = "Helvetica-Bold"
    }
    
    override func didMove(to view: SKView) {
        fontSetup(label: backNode, posX: -self.frame.width/5, posY: self.frame.height/3)
        backNode.name = "backLabel"
        addChild(backNode)
        
        fontSetup(label: searchNode, posX: self.frame.width/5, posY: self.frame.height/3)
        searchNode.name = "searchLabel"
        addChild(searchNode)
        
        //setup text field
        searchTextField = UITextField(frame: CGRect(x: view.frame.width/100, y: view.frame.height/5, width: view.frame.width/1.1, height: view.frame.height/25))

        searchTextField.backgroundColor = .clear
        searchTextField.placeholder = "Search for a song"
        searchTextField.layer.borderColor = UIColor.black.cgColor
        searchTextField.layer.borderWidth = 2.0
        searchTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        self.view?.addSubview(searchTextField)
        
        //setup song results table
        songTableView.selectProtocol = self
        songTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        songTableView.frame = CGRect(x: view.frame.width/100, y: searchTextField.frame.midY + searchTextField.frame.height, width: view.frame.width/1.1, height: view.frame.height/4)
        songTableView.backgroundColor = .clear
        songTableView.layer.borderWidth = 2.0
        songTableView.layer.borderColor = UIColor.black.cgColor
        self.view?.addSubview(songTableView)
        songTableView.reloadData()
        
        //setup ytplayer
        ytPlayer = YTPlayerView(frame: CGRect(x: view.frame.width/100, y: songTableView.frame.midY + songTableView.frame.height/1.5, width: view.frame.width/1.1, height: view.frame.height/4))
        ytPlayer.delegate = self
        
        //webView = UIWebView(frame: CGRect(x: view.frame.width/100, y: songTableView.frame.midY + songTableView.frame.height/1.5, width: view.frame.width/1.1, height: view.frame.height/4))
        //webView.allowsInlineMediaPlayback = true
        //webView.mediaPlaybackRequiresUserAction = false
        
        fontSetup(label: startNode, posX: 0, posY: -self.frame.height/2.2)
        startNode.name = "startLabel"
        addChild(startNode)
        
        
    }
    
    func didSelectRow(row: IndexPath, data: Song) {
        print("row: \(row.row) and string: \(data.title)")
        ytPlayer.removeFromSuperview()
        ytPlayer.load(withVideoId: data.videoId, playerVars: playerParam)
        self.view?.addSubview(ytPlayer)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch(state) {
            case .ended:
                playerView.playVideo()
            default:
                break
        
        }
       
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
                searchTextField.removeFromSuperview()
                songTableView.removeFromSuperview()
                ytPlayer.removeFromSuperview()
                self.view?.presentScene(scene, transition: rightTransition)
            }
        }
        else if (startNode.contains(location!)) {
            if let scene = GameScene(fileNamed: "GameScene") {
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.ytPlayer = ytPlayer
                searchTextField.removeFromSuperview()
                songTableView.removeFromSuperview()
                ytPlayer.isHidden = true
                self.view?.presentScene(scene, transition: leftTransition)
            }
        }
        else if (searchNode.contains(location!)) {
            if let searchTerm = searchTextField.text {
                print(searchTerm)
                //replace spaces for url call
                let newSearch = searchTerm.replacingOccurrences(of: " ", with: "%20")
                print(newSearch)
                songTableView.songArray.removeAll()
                getJSON(url: apiUrl + newSearch + apiKey)
            }
            
        }
        
    }
    
    func getJSON(url: String) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: URL(string: url)!)
        
        let task: URLSessionTask = session.dataTask(with: request) { (receivedData, response, error) -> Void in
            
            if let data = receivedData {
                var jsonResponse: [String:AnyObject]?
                
                do {
                    jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:AnyObject]
                    //print("NEW JSON")
                    //print(jsonResponse!)
                    
                }
                catch {
                    print("Caught Exception")
                }
                
                if let key1 = jsonResponse?["items"] {
                    if let key2 = key1 as? NSArray {
                        for item in key2 {
                            if let ytDict = item as? NSDictionary {
                                if let idDict = ytDict["id"] as? NSDictionary, let snippet = ytDict["snippet"] as? NSDictionary {
                                    if let videoId = idDict["videoId"] as? String, let title = snippet["title"] as? String, let channel = snippet["channelTitle"] as? String {
                                        self.songTableView.songArray.append(Song(title: title, artist: channel, videoId: videoId))
                                    }
                                }

                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.songTableView.reloadData()
                }
            }
        }
        
        task.resume()
    }
}
