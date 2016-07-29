//
//  RoomCell.swift
//  live
//
//  Created by swift on 16/7/28.
//  Copyright © 2016年 chensb. All rights reserved.
//

import UIKit

class RoomCell: UITableViewCell{
    
    @IBOutlet weak var roomName: UILabel!
    var  name:String?{
        didSet{
            self.roomName.text = name
        }
        
    }
    
}
