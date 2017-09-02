//
//  GameScene.swift
//  AstroJump
//
//  Created by James Ly on 5/13/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVKit
import AVFoundation
import youtube_ios_player_helper
import Firebase

// MARK: - Game States
enum GameStatus: Int {
    case waitingForTap = 0
    case playing = 1
    case gameOver = 2
    case paused = 3
}
enum PlayerStatus: Int {
    case idle = 0
    case jump = 1
    case fall = 2
    case lava = 3
    case dead = 4
}

struct PhysicsCategory {
    static let None: UInt32              = 0
    static let Player: UInt32            = 0b1
    static let PlatformNormal: UInt32    = 0b10
    static let PlatformBreakable: UInt32 = 0b100
    static let CoinNormal: UInt32        = 0b1000
    static let CoinSpecial: UInt32       = 0b10000
    static let Edges: UInt32             = 0b100000
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties

    var bgNode: SKNode!
    var fgNode: SKNode!
    var bgMusic: SKAudioNode!
    let cameraNode = SKCameraNode()
    var backgroundOverlayTemplate: SKNode!
    var backgroundOverlayHeight: CGFloat!
    var lava: SKSpriteNode!
    var player: SKSpriteNode!
    var gameState = GameStatus.waitingForTap
    var playerState = PlayerStatus.idle
    let motionManager = CMMotionManager()
    var xAcceleration = CGFloat(0)
    var avPlayer: AVAudioPlayer?
    var selectedSongName: String?
    var ytPlayer: YTPlayerView?
    var nameTextField: UITextField?
    var backNode = SKLabelNode(text: "Main Menu")
    var submitNode = SKLabelNode(text: "Submit")
    var pauseLabel : UILabel!
    var pauseMsg1 = SKLabelNode(text: "Game Paused")
    var pauseMsg2 = SKLabelNode(text: "Tap Anywhere to continue")
    var lastVelocityDY = CGFloat(0)
    
    //platform and coin nodes
    var platform5Across: SKSpriteNode!
    var platformDiagonal: SKSpriteNode!
    var breakable5Across: SKSpriteNode!
    var breakableDiagonal: SKSpriteNode!
    var coinArrow: SKSpriteNode!
    var coinDiagonal: SKSpriteNode!
    var coinCross: SKSpriteNode!
    var coin5Across: SKSpriteNode!
    var lastOverlayPosition = CGPoint.zero
    var lastOverlayHeight: CGFloat = 0.0
    var levelPositionY: CGFloat = 0.0
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    var lives = 3
    var coinScore = 0
    let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    

    override func didMove(to view: SKView) {
        setupNodes()
        setupLevel()
        setupPlayer()
        let scale = SKAction.scale(to: 1.0, duration: 0.5)
        fgNode.childNode(withName: "Ready")!.run(scale)
        setupCoreMotion()
        physicsWorld.contactDelegate = self
        
        livesLabel.text = "Lives: 3 Coins: 0"
        livesLabel.fontColor = .white
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .top
        livesLabel.position = CGPoint(x: -size.width/2, y: size.height/2)
        cameraNode.addChild(livesLabel)
        
        pauseLabel = UILabel(frame: CGRect(x: (self.view?.frame.width)!/1.2, y: (self.view?.frame.height)!/100, width: (self.view?.frame.width)!/10, height: (self.view?.frame.width)!/10))
        pauseLabel.text = "||"
        pauseLabel.textColor = .blue
        pauseLabel.font = UIFont(name: "Helvetica-Bold", size: 100)
        pauseLabel.textAlignment = .center
        pauseLabel.layer.borderWidth = 3.0
        pauseLabel.layer.borderColor = UIColor.white.cgColor
        pauseLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(GameScene.tapPause))
        pauseLabel.addGestureRecognizer(tap)
        self.view?.addSubview(pauseLabel)
        
        pauseMsg1.fontSize = 100
        pauseMsg1.zPosition = 150
        pauseMsg1.fontColor = .white
        pauseMsg1.fontName = "Helvetica-Bold"
        
        pauseMsg2.fontSize = 100
        pauseMsg2.zPosition = 150
        pauseMsg2.fontColor = .white
        pauseMsg2.fontName = "Helvetica-Bold"

        //preset songs use avplayer
        if (selectedSongName != nil) {
            if let url = NSDataAsset(name: selectedSongName!) {
                do {
                    try avPlayer = AVAudioPlayer(data: url.data)
                    avPlayer?.numberOfLoops = -1
                    avPlayer?.play()
                }
                catch {
                    print("error init avplayer")
                }
            }
        }
        
        camera?.position = CGPoint(x: size.width/2, y: size.height/2)

    }
    
    //load all the nodes
    func setupNodes() {
        let worldNode = childNode(withName: "World")!
        bgNode = worldNode.childNode(withName: "Background")!
        backgroundOverlayTemplate = bgNode.childNode(withName: "Overlay")!.copy() as! SKNode
        backgroundOverlayHeight = backgroundOverlayTemplate.calculateAccumulatedFrame().height
        fgNode = worldNode.childNode(withName: "Foreground")!
        player = fgNode.childNode(withName: "Player") as! SKSpriteNode
        platform5Across = loadForegroundOverlayTemplate("Platform5Across")
        platformDiagonal = loadForegroundOverlayTemplate("PlatformDiagonal")
        breakable5Across = loadForegroundOverlayTemplate("Breakable5Across")
        breakableDiagonal = loadForegroundOverlayTemplate("BreakableDiagonal")
        
        coinArrow = loadForegroundOverlayTemplate("CoinArrow")
        coinCross = loadForegroundOverlayTemplate("CoinCross")
        coinDiagonal = loadForegroundOverlayTemplate("CoinDiagonal")
        coin5Across = loadForegroundOverlayTemplate("Coin5Across")
        setupLava()
        
        addChild(cameraNode)
        camera = cameraNode
    }
    
    //place intial platform and start generating foregrounds
    func setupLevel() {
        // Place initial platform
        let initialPlatform = platform5Across.copy() as! SKSpriteNode
        var overlayPosition = player.position
        overlayPosition.y = player.position.y -
            ((player.size.height * 0.5) +
                (initialPlatform.size.height * 0.20))
        initialPlatform.position = overlayPosition
        fgNode.addChild(initialPlatform)
        lastOverlayPosition = overlayPosition
        lastOverlayHeight = initialPlatform.size.height / 2.0
        
        // Create random level
        levelPositionY = bgNode.childNode(withName: "Overlay")!
            .position.y + backgroundOverlayHeight
        while lastOverlayPosition.y < levelPositionY {
            addRandomForegroundOverlay()
        }
    }
    
    //set up physics body for collision dectection
    func setupPlayer() {
        player.physicsBody = SKPhysicsBody(circleOfRadius:
            player.size.width * 0.3)
        player.physicsBody!.isDynamic = false
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.collisionBitMask = 0
    }
    
    //set up motion manager
    func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.2
        let queue = OperationQueue()
        motionManager.startAccelerometerUpdates(to: queue,
                                                withHandler:
            {
                accelerometerData, error in
                guard let accelerometerData = accelerometerData else {
                    return
                }
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.25)
        })
    }
    
    
    // MARK: - Overlay nodes

    //load platform or coin scene
    func loadForegroundOverlayTemplate(_ fileName: String) ->
        SKSpriteNode {
            let overlayScene = SKScene(fileNamed: fileName)!
            let overlayTemplate =
                overlayScene.childNode(withName: "Overlay")
            return overlayTemplate as! SKSpriteNode
    }

    //keep track of foreground Y position and add new ones
    func createForegroundOverlay(_ overlayTemplate:
        SKSpriteNode, flipX: Bool) {
        let foregroundOverlay = overlayTemplate.copy() as!
        SKSpriteNode
        lastOverlayPosition.y = lastOverlayPosition.y +
            (lastOverlayHeight + (foregroundOverlay.size.height / 2.0))
        lastOverlayHeight = foregroundOverlay.size.height / 2.0
        foregroundOverlay.position = lastOverlayPosition
        if flipX == true {
            foregroundOverlay.xScale = -1.0
        }
        fgNode.addChild(foregroundOverlay)
    }
    
    //load background images
    func createBackgroundOverlay() {
        let backgroundOverlay = backgroundOverlayTemplate.copy() as!
        SKNode
        backgroundOverlay.position = CGPoint(x: 0.0, y: levelPositionY)
        bgNode.addChild(backgroundOverlay)
        levelPositionY += backgroundOverlayHeight
    }
    
    //randomly add platforms and coins
    func addRandomForegroundOverlay() {
        let overlaySprite: SKSpriteNode!
        let platformPercentage = 60
        let rng = Int(arc4random_uniform(UInt32(100)))
        if rng <= platformPercentage {
            if rng <= 10 {
                overlaySprite = breakableDiagonal
            }
            else if rng <= 20{
                overlaySprite = breakable5Across
            }
            else if rng <= 40{
                overlaySprite = platformDiagonal
            }
            else {
                overlaySprite = platform5Across
            }
        } else {
            if rng <= 70 {
                overlaySprite = coinArrow
            }
            else if rng <= 80 {
                overlaySprite = coinCross
            }
            else if rng <= 90 {
                overlaySprite = coinDiagonal
            }
            else {
                overlaySprite = coin5Across
            }
        }
        createForegroundOverlay(overlaySprite, flipX: false)
    }
    
    //load particle file for lava
    func setupLava() {
        lava = fgNode.childNode(withName: "Lava") as! SKSpriteNode
        let emitter = SKEmitterNode(fileNamed: "Lava.sks")!
        emitter.particlePositionRange = CGVector(dx: size.width
            * 1.125, dy: 0.0)
        emitter.advanceSimulationTime(3.0)
        lava.addChild(emitter)
    }
    
    //add score to firebae
    func sendScoreToFirebase() {
        let leaderboardRoot = Database.database().reference(withPath: "Leaderboard")
        let newScore = Score(player: (nameTextField?.text)!, score: coinScore)
        let newRef = leaderboardRoot.child(newScore.player)
        newRef.setValue(newScore.toAnyObject())
    }
    
    //pause game
    func tapPause(sender: UITapGestureRecognizer) {
        if gameState == .playing {
            gameState = .paused
            //save velocity in y direction
            lastVelocityDY = (player.physicsBody?.velocity.dy)!
            
            player.physicsBody?.isDynamic = false
            pauseMsg1.position = camera!.position
            pauseMsg2.position = CGPoint(x: camera!.position.x, y: camera!.position.y - (self.view?.frame.height)!/10)
            addChild(pauseMsg1)
            addChild(pauseMsg2)
            
            ytPlayer?.pauseVideo()
            avPlayer?.pause()
        }
    }
    
    // MARK: - Events
    override func touchesBegan(_ touches: Set<UITouch>, with event:
        UIEvent?) {
        let location = touches.first?.location(in: self)
        if gameState == .waitingForTap {
            let scale = SKAction.scale(to: 0, duration: 0.4)
            fgNode.childNode(withName: "Ready")!.run(
                SKAction.sequence(
                    [SKAction.wait(forDuration: 0.2), scale]))
            
            gameState = .playing
            player.physicsBody!.isDynamic = true
            superBoostPlayer()
            
        }
        if gameState == .paused {
            player.physicsBody?.isDynamic = true
            player.physicsBody?.velocity.dy = lastVelocityDY
            removeChildren(in: [pauseMsg1, pauseMsg2])
            
            ytPlayer?.playVideo()
            avPlayer?.play()
            gameState = .playing
        }
        if gameState == .gameOver {
            let menu = MainMenuScene(fileNamed: "MainMenuScene")
            menu!.scaleMode = .aspectFill
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            if (submitNode.contains(location!)) {
                if (nameTextField?.text != "") {
                    sendScoreToFirebase()
                    avPlayer?.stop()
                    ytPlayer?.removeFromSuperview()
                    nameTextField?.removeFromSuperview()
                    self.view?.presentScene(menu!, transition: reveal)
                }
            }
            else if (backNode.contains(location!)) {
                avPlayer?.stop()
                ytPlayer?.removeFromSuperview()
                nameTextField?.removeFromSuperview()
                self.view?.presentScene(menu!, transition: reveal)
            }
        }
    }
    
    //sets how far player can jump
    func setPlayerVelocity(_ amount:CGFloat) {
        let gain: CGFloat = 1.5
        player.physicsBody!.velocity.dy =
            max(player.physicsBody!.velocity.dy, amount * gain)
    }
    func jumpPlayer() {
        setPlayerVelocity(660)
    }
    func boostPlayer() {
        setPlayerVelocity(1200)
    }
    func superBoostPlayer() {
        setPlayerVelocity(1700)
    }
    
    //run particle file on sprite
    func emitParticles(name: String, sprite: SKSpriteNode) {
        let pos = fgNode.convert(sprite.position,
                                 from: sprite.parent!)
        let particles = SKEmitterNode(fileNamed: name)!
        particles.position = pos
        particles.zPosition = 3
        fgNode.addChild(particles)
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        particles.run(SKAction.sequence([wait, remove]))
        sprite.run(SKAction.sequence(
            [SKAction.scale(to: 0.0, duration: 0.5),
             SKAction.removeFromParent()]))
    }
    
    //collision detection
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask ==
            PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.CoinNormal:
            if let coin = other.node as? SKSpriteNode {
                coinScore += 1
                jumpPlayer()
                emitParticles(name: "CollectNormal", sprite: coin)
            }
        case PhysicsCategory.CoinSpecial:
            if let coin = other.node as? SKSpriteNode {
                //coin.removeFromParent()
                coinScore += 5
                boostPlayer()
                emitParticles(name: "CollectSpecial", sprite: coin)
            }
        case PhysicsCategory.PlatformBreakable:
            if let plat = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    jumpPlayer()
                    emitParticles(name: "BrokenPlatform", sprite: plat)
                }
            }
        case PhysicsCategory.PlatformNormal:
            if let _ = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    jumpPlayer()
                }
            }
        default:
            break
        }
    }
    
    func sceneCropAmount() -> CGFloat {
        guard let view = self.view else {
            return 0 }
        let scale = view.bounds.size.height / self.size.height
        let scaledWidth = self.size.width * scale
        let scaledOverlap = scaledWidth - view.bounds.size.width
        return scaledOverlap / scale
    }
    
    
    func updatePlayer() {
        // Set velocity based on core motion
        player.physicsBody?.velocity.dx = xAcceleration * 1000.0
        // Wrap player around edges of screen
        var playerPosition = convert(player.position, from: fgNode)
        let leftLimit = sceneCropAmount()/2 - player.size.width/2
        let rightLimit = size.width - sceneCropAmount()/2
            + player.size.width/2
        if playerPosition.x < leftLimit {
            playerPosition = convert(CGPoint(x: rightLimit, y: 0.0),
                                     to: fgNode)
            player.position.x = playerPosition.x
        }
        else if playerPosition.x > rightLimit {
            playerPosition = convert(CGPoint(x:
                leftLimit, y: 0.0), to: fgNode)
            player.position.x = playerPosition.x
        }
        // Check player state
        if player.physicsBody!.velocity.dy < CGFloat(0.0) &&
            playerState != .fall {
            playerState = .fall

        } else if player.physicsBody!.velocity.dy > CGFloat(0.0) &&
            playerState != .jump {
            playerState = .jump

        }
    }
    
    //add smoke trail particle
    func addTrail(name: String) -> SKEmitterNode {
        let trail = SKEmitterNode(fileNamed: name)!
        trail.zPosition = -1
        trail.targetNode = fgNode
        player.addChild(trail)
        return trail
    }
    
    //remove smoke trail particle
    func removeTrail(trail: SKEmitterNode) {
        trail.numParticlesToEmit = 1
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        //wait 1 sec before removing
        trail.run(SKAction.sequence([wait, remove]))
    }
    
    //make lava slowly rise
    func updateLava(_ dt: TimeInterval) {
        
        let bottomOfScreenY = camera!.position.y - (size.height / 2)
       
        let bottomOfScreenYFg = convert(CGPoint(x: 0, y: bottomOfScreenY), to: fgNode).y
       
        let lavaVelocityY = CGFloat(130)
        let lavaStep = lavaVelocityY * CGFloat(dt)
        var newLavaPositionY = lava.position.y + lavaStep
        
        newLavaPositionY = max(newLavaPositionY, (bottomOfScreenYFg - 125.0))
        
        lava.position.y = newLavaPositionY
    }
    
    //detect player collision with lava
    func updateCollisionLava() {
        if player.position.y < lava.position.y + 180 {
            if playerState != .lava {
                playerState = .lava
                let smokeTrail = addTrail(name: "SmokeTrail")
                run(SKAction.sequence([
                    SKAction.wait(forDuration: 3.0),
                    SKAction.run() {
                        self.removeTrail(trail: smokeTrail)
                    }
                    ])) }
            boostPlayer()
            lives -= 1
            if lives <= 0 {
                gameOver()
            }
        }
    }
    
    //helper func to tell if node is visible to camera
    func isNodeVisible(_ node: SKNode, positionY: CGFloat) -> Bool {
        if !camera!.contains(node) {
            if positionY < camera!.position.y - size.height * 2.0 {
                return false
            }
        }
        return true
    }
    
    //repeats background when camera goes past levelPosition
    func updateLevel() {
        let cameraPos = camera!.position
        if cameraPos.y > levelPositionY - (size.height * 0.55) {
            createBackgroundOverlay()
            while lastOverlayPosition.y < levelPositionY {
                addRandomForegroundOverlay()
            }
        }
        
        // remove old foreground nodes
        for fgChild in fgNode.children {
            let nodePos = fgNode.convert(fgChild.position, to: self)
            if !isNodeVisible(fgChild, positionY: nodePos.y) {
                fgChild.removeFromParent()
            }
        }
    }
    
    //have camera follow the player
    func updateCamera() {

        let cameraTarget = convert(player.position, from: fgNode)

        var targetPositionY = cameraTarget.y - (size.height * 0.10)
        let lavaPos = convert(lava.position, from: fgNode)
        targetPositionY = max(targetPositionY, lavaPos.y)

        let diff = targetPositionY - camera!.position.y

        let cameraLagFactor = CGFloat(0.2)
        let lagDiff = diff * cameraLagFactor
        let newCameraPositionY = camera!.position.y + lagDiff

        camera!.position.y = newCameraPositionY
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        // calc time between current and last update
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        lastUpdateTimeInterval = currentTime
        // check if game is paused
        if gameState == .paused {
            return
        }
        // check if currently playing
        else if gameState == .playing {
            updateCamera()
            updateLevel()
            updatePlayer()
            updateLava(deltaTime)
            updateCollisionLava()
            livesLabel.text = "Lives: \(lives) Coins: \(coinScore)"
        }
    }
    
    func gameOver() {

        
        // set states to end updates
        gameState = .gameOver
        playerState = .dead
        pauseLabel.removeFromSuperview()

        physicsWorld.contactDelegate = nil
        player.physicsBody?.isDynamic = false
        // remove player from screen
        let moveUp = SKAction.moveBy(x: 0.0, y: size.height/2.0, duration: 0.5)
        moveUp.timingMode = .easeOut
        let moveDown = SKAction.moveBy(x: 0.0, y: -(size.height * 1.5), duration: 1.0)
        moveDown.timingMode = .easeIn
        player.run(SKAction.sequence([moveUp, moveDown]))
        // display game over
        let gameOverSprite = SKSpriteNode(imageNamed: "GameOver")
        gameOverSprite.position = camera!.position
        gameOverSprite.zPosition = 10
        addChild(gameOverSprite)
        
        //add stuff for score submission
        nameTextField = UITextField(frame: CGRect(x: (self.view?.frame.width)!/100, y: (self.view?.frame.height)!/5, width: (self.view?.frame.width)!/1.1, height: (self.view?.frame.height)!/25))
        
        
        nameTextField?.backgroundColor = SKColor.white
        nameTextField?.placeholder = "Enter a name to submit score"
        self.view?.addSubview(nameTextField!)
        
        //submit button
        submitNode.position = CGPoint(x: camera!.position.x - (self.view?.frame.width)!/1.5, y: camera!.position.y + (self.view?.frame.height)!/3)
        submitNode.name = "submitLabel"
        submitNode.zPosition = 15
        submitNode.fontColor = .white
        submitNode.fontSize = 100
        submitNode.fontName = "Helvetica-Bold"
        addChild(submitNode)
        
        //main menu button
        backNode.position = CGPoint(x: camera!.position.x + (self.view?.frame.width)!/2, y: camera!.position.y + (self.view?.frame.height)!/3)
        backNode.name = "backLabel"
        backNode.zPosition = 15
        backNode.fontColor = .white
        backNode.fontSize = 100
        backNode.fontName = "Helvetica-Bold"
        addChild(backNode)
        
    }
    
}
