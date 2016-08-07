//
//  SingletonSocket.swift
//  live
//
//  Created by swift on 16/7/28.
//  Copyright © 2016年 chensb. All rights reserved.
//

import SwiftWebSocket
import lf
enum MyErrorEnum : ErrorType {
    case NODATA
}
class SingletonSocket {
    let ws = WebSocket(WS)

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
        
                    self.ws.event.message = { message in
                        do {
                           var m = message as! [UInt8]
                            let len = m.count
                          
                            
                            let start = sizeof(UInt64) * 2
                            if start >= len {
                                print(start,len)
                                throw(MyErrorEnum.NODATA)
                            }
                        
//                            uin64(len),uint64(protoType),uint8(mediaType),mediaData....
                            let typeByte = Array(Array(m[8...15]).reverse())
                            let typeRaw = self.fromByteArray(typeByte, UInt64.self)
                            let type = ProtoType(rawValue: typeRaw)
                            let m1 = Array(m[start...len-1])
                            let data = NSData(bytes: m1 as [UInt8]   , length: m1.count * sizeof(UInt8))
                            ProtoHandler.sharedInstance.protoHandler(type!, data: data)

                        }catch {
                            print(error)
                        }
                        
                    }

    }
    class var sharedInstance : SingletonSocket{
        struct Static {
            static let instance:SingletonSocket = SingletonSocket()
                
        }
        return Static.instance
    }

    func fromByteArray<T>(value: [UInt8], _: T.Type) -> T {
        return value.withUnsafeBufferPointer {
            return UnsafePointer<T>($0.baseAddress).memory
        }
    }
    
    func toByteArray<T>( var value: T) -> [UInt8] {
        return withUnsafePointer(&value) {
            Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(T)))
        }
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
            
        }catch _ {
            print("build err")
            
        }
    }
    func joinRoom(id: Int64) {
        let joinRoomsBuilder = Myproto.JoinRoomTos.Builder()
        do {
            self.ws.open()
            joinRoomsBuilder.setRoomId(id)
            let joinRoom =  try joinRoomsBuilder.build()
            let  protoData = joinRoom.data()
            let data = NSMutableData()
            var len :UInt64 =  CFSwapInt64HostToBig(UInt64(sizeof(Int64) * 2 + protoData.length))
            data.appendBytes(&len, length: sizeof(Int64))
            var messageType = CFSwapInt64HostToBig(1002)
            data.appendBytes(&messageType, length: sizeof(Int64))
            
            data.appendBytes(protoData.bytes, length: protoData.length)
            
            self.ws.send(data)
        }catch _ {
            print("build err")
            
        }
    }
    func pushStream(type: StreamType, data : NSData,competion:()->()){

            let protoData = NSMutableData()
        
            var len  =  self.toByteArray(CFSwapInt64HostToBig(UInt64(sizeof(Int64) * 2 + sizeof(UInt8) + data.length)))
        
            protoData.appendBytes(&len, length: sizeof(Int64))
            var liveType  =  Array(self.toByteArray(255 as UInt64).reverse())
            protoData.appendBytes(&liveType, length: sizeof(UInt64))
            var streamType = self.toByteArray(type.rawValue as UInt8 )
            protoData.appendBytes(&streamType, length: sizeof(UInt8))
           // log.info("protodata \(protoData)")
            protoData.appendBytes(data.bytes, length: data.length)
            self.ws.send(protoData)
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




