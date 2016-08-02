//
//  WatchStreamViewController.swift
//  live
//
//  Created by chsb on 16/8/2.
//  Copyright © 2016年 chensb. All rights reserved.
//

import UIKit

class WatchStreamViewController: ViewController {

    enum NALUType:UInt8{
        case NALUTypeSliceNoneIDR = 1,
         NALUTypeSliceIDR = 5,
         NALUTypeSPS = 7,
         NALUTypePPS = 8
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        SingletonSocket.sharedInstance.ws.event = {
            message in
            self.parseNLU(message)
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseNLU(message:NSData){
        type = self.getNALUType(message)
        print(type)
    }
    
    func getNALUType(NALU:NSData) -> NALUType{
       var array = [UInt8](count: 1, repeatedValue: 0)
        NALU.getBytes(&array, length: sizeof(UInt8))
        type: NALUType = (array[0] & 0x1F)
        return type

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
