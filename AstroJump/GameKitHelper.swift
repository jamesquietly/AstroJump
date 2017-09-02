//
//  GameKitHelper.swift
//  AstroJump
//
//  Created by James Ly on 5/23/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit
import Foundation
import GameKit

class GameKitHelper: NSObject {
    static let sharedInstance = GameKitHelper()
    static let PresentAuthenticationViewController = "PresentAuthenticationViewController"
    var authenticationViewController: UIViewController?
    var gameCenterEnabled = false
    var gcDefaultLeaderboard = String()
    
    func authenticateLocalPlayer() {

        GKLocalPlayer.localPlayer().authenticateHandler =
            { (viewController, error) in

                self.gameCenterEnabled = false
                if viewController != nil {
                    self.authenticationViewController = viewController
                    NotificationCenter.default.post(name: NSNotification.Name(GameKitHelper.PresentAuthenticationViewController),object: self)
                } else if GKLocalPlayer.localPlayer().isAuthenticated {
                    self.gameCenterEnabled = true
                    GKLocalPlayer.localPlayer().loadDefaultLeaderboardIdentifier(completionHandler: {
                        (leaderboardIdentifier, error) in
                        if error != nil {
                            print(error)
                        }
                        else {
                            self.gcDefaultLeaderboard = leaderboardIdentifier!
                        }
                    })
                }
        } }
}
