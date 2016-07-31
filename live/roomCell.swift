//
//  RoomCell.swift
//  live
//
//  Created by swift on 16/7/28.
//  Copyright © 2016年 chensb. All rights reserved.
//

import UIKit

class   RoomCell: UITableViewCell{
    
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var curRoomUserLabel: UILabel!
    var  roomName:String?{
        didSet{
            print("set cell room name \(self.roomName)")
            self.roomNameLabel.text = self.roomName
        }
        
    }
    
}
