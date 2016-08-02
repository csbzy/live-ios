//
//  SingletonSocket.swift
//  live
//
//  Created by swift on 16/7/28.
//  Copyright © 2016年 chensb. All rights reserved.
//

import SwiftWebSocket

enum MyErrorEnum : ErrorType {
    case NODATA
}
class SingletonSocket {
    let ws = WebSocket(WS)
    weak var viewController: LiveRoomViewController?
    init(){
        self.ws.event.close = {
            code, reason, clean in
            print("ws cloese  \(reason)  ")
        }
        ws.services = [.VoIP,.Background]
        
        self.ws.event.pong = {
            data in
            print("receive poing \(data)")
        }
        self.ws.open()
        self.ws.ping()

    }
    class var sharedInstance : SingletonSocket{
        struct Static {
            static let instance:SingletonSocket = SingletonSocket()
                
        }
        return Static.instance
    }

    func getRoom(){
        let getRoomsBuilder = Myproto.GetRoomsTos.Builder()
        do {
            self.ws.open()
            getRoomsBuilder.setId(1000)
            let getRooms =  try getRoomsBuilder.build()
            let  protoData = getRooms.data()
            let data = NSMutableData()
            var len :UInt64 =  CFSwapInt64HostToBig(UInt64(sizeof(Int64) * 2 + protoData.length))
            data.appendBytes(&len, length: sizeof(Int64))
            var messageType = CFSwapInt64HostToBig(1008)
            data.appendBytes(&messageType, length: sizeof(Int64))
            
            data.appendBytes(protoData.bytes, length: protoData.length)
            
            self.ws.send(data)

            print("get room")
            self.ws.event.message = { message in
                do {
                    var m = message as! [UInt8]
                    let len = m.count
                    print(m)
                    let start = sizeof(UInt64) * 2
                    if start >= len {
                        print(start,len)
                        throw(MyErrorEnum.NODATA)
                    }
                    let m1 = Array(m[start...len-1])
                    
                    let data = NSData(bytes: m1 as [UInt8]   , length: m1.count * sizeof(UInt8))
                    let  rooms =  try Myproto.GetRoomToc.parseFromData( data)
                    self.viewController!.rooms = rooms.room
                }catch {
                    print(error)
                }
                
            }
            
            
        }catch _ {
            print("build err")
            
        }
    }
    func createRoom(name: String) {
        let createRoomsBuilder = Myproto.CreateRoomTos.Builder()
        do {
            self.ws.open()
            createRoomsBuilder.setRoomName(name)
            let createRoom =  try createRoomsBuilder.build()
            let  protoData = createRoom.data()
            let data = NSMutableData()
            var len :UInt64 =  CFSwapInt64HostToBig(UInt64(sizeof(Int64) * 2 + protoData.length))
            data.appendBytes(&len, length: sizeof(Int64))
            var messageType = CFSwapInt64HostToBig(1000)
            data.appendBytes(&messageType, length: sizeof(Int64))
            
            data.appendBytes(protoData.bytes, length: protoData.length)
            
            self.ws.send(data)
            self.ws.event.message = { message in
                do {
                    var m = message as! [UInt8]
                    let len = m.count
                    print(m)
                    let start = sizeof(UInt64) * 2
                    if start >= len {
                        print(start,len)
                        throw(MyErrorEnum.NODATA)
                    }
                    let m1 = Array(m[start...len-1])
                    
                    let data = NSData(bytes: m1 as [UInt8]   , length: m1.count * sizeof(UInt8))
                    print(try Myproto.CreateRoomToc.parseFromData( data))
                    self.getRoom()
                }catch {
                    print(error)
                }
                
            }
            
            
        }catch _ {
            print("build err")
            
        }
    }
    
    func pushStream(type: Int64, data : NSData,competion:()->()){
        let liveStream = Myproto.LiveTos.Builder()
        do {
            self.ws.open()
            liveStream.setData(data)
            liveStream.setTypes(type)
            let liveStreamData =  try liveStream.build()
            let  protoData = liveStreamData.data()
            let data = NSMutableData()
            var len :UInt64 =  CFSwapInt64HostToBig(UInt64(sizeof(Int64) * 2 + protoData.length))
            data.appendBytes(&len, length: sizeof(Int64))
            var messageType = CFSwapInt64HostToBig(1006)
            data.appendBytes(&messageType, length: sizeof(Int64))
            
            data.appendBytes(protoData.bytes, length: protoData.length)
            print1(data)
            self.ws.send(data)
            self.ws.event.message = { message in
                do {
                    var m = message as! [UInt8]
                    let len = m.count
                    print(m)
                    let start = sizeof(UInt64) * 2
                    if start >= len {
                        print(start,len)
                        throw(MyErrorEnum.NODATA)
                    }
                    let m1 = Array(m[start...len-1])
                    
                    let data = NSData(bytes: m1 as [UInt8]   , length: m1.count * sizeof(UInt8))
                    print(try Myproto.LiveToc.parseFromData( data))
                    competion()
                }catch {
                    print(error)
                }
                
            }
            
            
        }catch _ {
            print("build err")
            
        }
    }
    
    func print1(nsData : NSData){
        
        let buffer = UnsafeBufferPointer<UInt8>(start:UnsafePointer<UInt8>(nsData.bytes), count:nsData.length)
        print("nsData: \(nsData)")
        
        var intData = [Int]()
        intData.reserveCapacity(nsData.length)
        
        var stringData = String()
        
        for i in 0..<nsData.length {
            intData.append(Int(buffer[i]))
            stringData += String(buffer[i])
        }
        
        print("intData: \(intData)")
        print("stringData: \(stringData)")
    }
}




