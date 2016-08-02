//
//  PushViewController.swift
//  LivePush
//
//  Created by 成杰 on 16/5/25.
//  Copyright © 2016年 swiftc.org. All rights reserved.
//

import UIKit
import CoreMedia

class PushViewController: UIViewController, VideoEncoderDelegate, AudioEncoderDelegate {

    private let vCapture = VideoCapture()
    private let aCapture = AudioCapture()
    
    private let vEncoder = VideoEncoder()
    private let aEncoder = AudioEncoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()
        
        vCapture.previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(vCapture.previewLayer)
                
        vEncoder.delegate = self
        aEncoder.delegate = self
        
        vCapture.startSession()
        
        vCapture.output { (sampleBuffer) in
            
            self.handleVideoSampleBuffer(sampleBuffer)
        }
        
        //aCapture.startSession()
        
        aCapture.output { (sampleBuffer) in
            
            self.handleAudioSampleBuffer(sampleBuffer)
        }
    }
    
    private func handleVideoSampleBuffer(sampleBuffer: CMSampleBuffer) {
        // TODO: some effect on here
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        guard imageBuffer != nil else { return }
        
        let timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let duration = CMSampleBufferGetDuration(sampleBuffer)
        
        vEncoder.encode(imageBuffer: imageBuffer!,
                        presentationTimeStamp: timeStamp,
                        presentationDuration: duration)
    }
    
    private func handleAudioSampleBuffer(sampleBuffer: CMSampleBuffer) {
        
        aEncoder.encode(sampleBuffer: sampleBuffer)
    }
    
    dynamic func stopCapture() {
        vCapture.stopSession()
        aCapture.stopSession()
    }
    
    // MARK: - VideoEncoderDelegate
    func onVideoEncoderGet(sps sps: NSData, pps: NSData) {
       // rtmpClient.send(sps: sps, pps: pps)
        //self.sps = sps
        //self.pps = pps
       // var live = Myproto.LiveTos.Builder()
        print("encode get sps")
        let nluData = NSMutableData()
//        SingletonSocket.sharedInstance.pushStream(<#T##data: NSData##NSData#>, competion: <#T##() -> ()#>)
//        if self.curFrameData.length > 0 {
//            SingletonSocket.sharedInstance.pushStream( self.curFrameData){
//                self.curFrameData = NSMutableData()
//                
//                
//                self.curFrameData.appendBytes(sps.bytes, length: sps.length)
//                self.curFrameData.appendBytes(pps.bytes,length: pps.length)
//            }
//        }else{
//            self.curFrameData.appendBytes(sps.bytes, length: sps.length)
//            self.curFrameData.appendBytes(pps.bytes,length: pps.length)
//        }
        nluData.appendBytes(sps.bytes, length: sps.length)
        nluData.appendBytes(pps.bytes,length: pps.length)
        SingletonSocket.sharedInstance.pushStream(1,data: sps){}
        
    }
    
    func onVideoEncoderGet(video video: NSData, timeStamp: Double, isKeyFrame: Bool) {
       // rtmpClient.send(video: video, timeStamp: timeStamp, isKeyFrame: isKeyFrame)
        //self.videoData = video
        
        SingletonSocket.sharedInstance.pushStream(2,data: video){}
    }
    
    // MARK: - AudioEncoderDelegate
    func onAudioEncoderGet(audio: NSData) {
        //rtmpClient.send(audio: audio)
        //self.audioData = audio
        SingletonSocket.sharedInstance.pushStream(3,data: audio){}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
