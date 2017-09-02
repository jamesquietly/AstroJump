//
//  SongTVC.swift
//  AstroJump
//
//  Created by James Ly on 5/21/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import UIKit

class SongTVC: UITableViewCell {
    var titleLabel: UILabel!

    init(frame: CGRect, title: String) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: "songCell")
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/2))
        titleLabel.textColor = .black
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
