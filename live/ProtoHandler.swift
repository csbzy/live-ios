//
//  ProtoHandler.swift
//  live
//
//  Created by chsb on 16/8/5.
//  Copyright © 2016年 chensb. All rights reserved.
//

import Foundation
import XCGLogger
import lf


enum ProtoType : UInt64{
    case CreateRoomToc = 1001,JoinRoomToc = 1003,LeaveRoomToc=1005,LiveTos=255,LiveToc=1007,GetRoomToc=1009
    
}


final class ProtoHandler{
    
    weak var liveViewController: LiveRoomViewController?
    weak var watchViewController:WatchStreamViewController?{
        didSet{
            log.info("set watchview")
        }
    }
    
    class var sharedInstance : ProtoHandler{
        struct Static {
            static let instance:ProtoHandler = ProtoHandler()
        }
        return Static.instance
    }
    func protoHandler(type:ProtoType,data:NSData){
        do{
            switch type {
            case .CreateRoomToc:
                
                
                let  createRoomToc =  try Myproto.CreateRoomToc.parseFromData( data)
                
                if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        
                        topController = presentedViewController
                    }
                    let videoViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("PushViewController") as! PushViewController
                    topController.presentViewController(videoViewController, animated: true) { () -> Void in
                    }

                }
               
                log.info("create room id  \(createRoomToc.roomId)")
            case .JoinRoomToc:
                XCGLogger.defaultInstance().info("join room ok")
            case .LiveTos:
                
                var payload = [UInt8](count: data.length, repeatedValue: 0x00)
                data.getBytes(&payload, length : data.length)
                
                let mediaType = UInt8(payload.removeAtIndex(0))
                //var payload = Array(dataArray[16...data.length-1])
               //log.info("media type \(mediaType), flv type: \(payload[1])")
                switch StreamType(rawValue:mediaType)! {
//                case .VOICE:
//                    //log.warning("not implement voice decode")
//                    
                case StreamType.VIDEO:
                    switch payload[1] {
                    case FLVAVCPacketType.Seq.rawValue:
                        self.watchViewController!.createFormatDescription(payload)
                    case FLVAVCPacketType.Nal.rawValue:
                        self.watchViewController!.enqueueSampleBuffer(payload)
                    default:
                        break
                    }
              default:
                    break
                }
                
            case .GetRoomToc:
                let  rooms =  try Myproto.GetRoomToc.parseFromData( data)
                self.liveViewController!.rooms = rooms.room
                
            default:
                print("no such type")
            }
        }catch {
    
        }
    
   }
} 

