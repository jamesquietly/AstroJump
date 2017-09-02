//
//  ASNavigationController.swift
//  AstroJump
//
//  Created by James Ly on 5/23/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit

class ASNavigationController: UINavigationController {
    static let sharedInstance = ASNavigationController()
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(showAuthenticationViewController),name: NSNotification.Name(GameKitHelper.PresentAuthenticationViewController), object: nil)
        GameKitHelper.sharedInstance.authenticateLocalPlayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAuthenticationViewController() {
        let gameKitHelper = GameKitHelper.sharedInstance
        if let authenticationViewController = gameKitHelper.authenticationViewController {
            topViewController?.present(authenticationViewController, animated: true, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
