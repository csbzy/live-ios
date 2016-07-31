//
//  ViewController.swift
//  live
//
//  Created by swift on 16/7/28.
//  Copyright © 2016年 chensb. All rights reserved.
//

import UIKit
class LiveRoomViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var roomTableView: UITableView!
    @IBOutlet weak var createRoomInput: UITextField!
    var rooms : Array<Myproto.Room>?{
        didSet{
            print("set rooms :\(self.rooms!)")
           self.roomTableView.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roomTableView.delegate = self
        self.roomTableView.dataSource = self
   
        self.roomTableView.estimatedRowHeight = self.roomTableView.rowHeight
        self.roomTableView.rowHeight = UITableViewAutomaticDimension
        SingletonSocket.sharedInstance.viewController = self
        SingletonSocket.sharedInstance.getRoom()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func refreshButton(sender: AnyObject) {
        SingletonSocket.sharedInstance.getRoom()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createRoom(sender: AnyObject) {
        
        if createRoomInput.text != "" {
            print("create room\(createRoomInput.text)")
            SingletonSocket.sharedInstance.createRoom(createRoomInput.text!)
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = self.roomTableView.indexPathForSelectedRow!;
        let videoViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("VideoStreamViewController") as! VideoStreamViewController
        
        self.presentViewController(videoViewController, animated: true) { () -> Void in
        }
        
        
        
    }
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.rooms != nil {
            return self.rooms!.count
        }else{
            return 0
        }
        
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RoomCell", forIndexPath: indexPath) as! RoomCell
        if self.rooms != nil   {
            cell.roomName = self.rooms![indexPath.row].roomName
        }
        return cell
    }
    
    
    

}

