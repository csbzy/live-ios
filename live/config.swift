//
//  config.swift
//  live
//
//  Created by swift on 16/7/28.
//  Copyright © 2016年 chensb. All rights reserved.
//

import Foundation
import XCGLogger
//let WS = "ws://127.0.0.1:8080/ws"

let WS = "ws://192.168.1.112:8080/ws"


func isRunningOniOSDevice() -> Bool {
    
    #if (arch(arm) && os(iOS)) || (arch(arm64) && os(iOS))
        return true
    #else
        return false
    #endif
}

let log = XCGLogger.defaultInstance()

enum StreamType :UInt8{
    case VOICE = 1,VIDEO = 2
}

