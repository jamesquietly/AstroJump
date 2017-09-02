//
//  SongTableView.swift
//  AstroJump
//
//  Created by James Ly on 5/15/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit
import SpriteKit

class SongTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    var songArray = [Song]()
    var currentSong : Song?
    var selectProtocol: SelectProtocol?
    
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
        return songArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        cell.textLabel?.text = songArray[indexPath.row].title
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSong = songArray[indexPath.row]
        self.selectProtocol?.didSelectRow(row: indexPath, data: songArray[indexPath.row])
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
