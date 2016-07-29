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
        self.socket?.connect()
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
           let getRooms =  try getRoomsBuilder.build()
            self.socket?.writeData(getRooms.data())

         }catch _ {
            print("not build")
        
            }
            }
}




