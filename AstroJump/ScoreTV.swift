//
//  ScoreTV.swift
//  AstroJump
//
//  Created by James Ly on 6/5/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit

class ScoreTV: UITableView, UITableViewDelegate, UITableViewDataSource {
    var scoreArray = [Score]()


    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let scoreItem = scoreArray[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.text = "\(scoreItem.player)  coins: \(scoreItem.coins)"
        return cell
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
