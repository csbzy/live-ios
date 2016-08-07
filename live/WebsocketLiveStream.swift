//
//  WebsocketLiveStream.swift
//  live
//
//  Created by chsb on 16/8/4.
//  Copyright © 2016年 chensb. All rights reserved.
//
import lf
import Foundation
import AVFoundation
import XCGLogger

class WebsocketLiveStream : Stream {
    
    enum StreamState {
        case STOP
        case PUSH
        case PULL
    }
    private var rtmpMuxer : RTMPMuxer = RTMPMuxer()
    var streamState:StreamState = .STOP{
        didSet {
            switch streamState {
            case .PUSH:
                self.mixer.audioIO.encoder.startRunning()
                self.mixer.videoIO.encoder.startRunning()
            default:
                break
            }
        }
    }
    func publish(){
        if self.streamState == .PUSH{
            log.info("pushing")
        }else{
            
            self.rtmpMuxer.dispose()
            self.rtmpMuxer.delegate = self
            #if os(iOS)
                self.mixer.videoIO.screen?.startRunning()
            #endif
            self.mixer.audioIO.encoder.delegate = self.rtmpMuxer
            self.mixer.videoIO.encoder.delegate = self.rtmpMuxer
            self.mixer.startRunning()
            self.streamState = .PUSH
        }
    
    }
    
    func stop(){
        self.streamState = .STOP
    }
}





extension WebsocketLiveStream: RTMPMuxerDelegate {
    func sampleOutput(muxer:RTMPMuxer, audio buffer:NSData, timestamp:Double) {
        guard self.streamState == .PUSH else {
            return
        }
        SingletonSocket.sharedInstance.pushStream(StreamType.VOICE,data: buffer){
            print("push data ok")
        }
    }
    
    func sampleOutput(muxer:RTMPMuxer, video buffer:NSData, timestamp:Double) {
        guard self.streamState == .PUSH else {
            return
        }
        SingletonSocket.sharedInstance.pushStream(StreamType.VIDEO,data: buffer){
            print("push data ok")
        }
    }
}
