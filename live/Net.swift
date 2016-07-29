//
//  Net.swift
//  live
//
//  Created by swift on 16/7/28.
//  Copyright © 2016年 chensb. All rights reserved.
//

import Starscream


class Socket :NSObject,WebSocketDelegate{
    var socket : WebSocket?
    override init (){
        super.init()
        print("start to connect")
        self.socket = WebSocket(url: NSURL(string:WS)!)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    func websocketDidConnect(socket:WebSocket){
        print("websocket connect")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("got some data: \(data.length)")
    }
    func getRoom(){
        let getRoomsBuilder = Myproto.GetRoomsTos.Builder()
         do {
            
            getRoomsBuilder.setId(1000)
           let getRooms =  try getRoomsBuilder.build()
            
           var  protoData = getRooms.data()
            
            var data = NSMutableData()
            var len :UInt64 =  CFSwapInt64HostToBig(UInt64(sizeof(Int64) * 2 + protoData.length )*2)
            data.appendBytes(&len, length: sizeof(Int64))
            var messageType = CFSwapInt64HostToBig(1008)
            data.appendBytes(&messageType, length: sizeof(Int64))
            
            data.appendBytes(&protoData, length: protoData.length)
            print("data\(getRooms.data())   ")
            self.socket?.writeData(NSData(data: data))

         }catch _ {
            print("not build")
        
            }
            }
}




