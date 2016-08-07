//
//  WatchStreamViewController.swift
//  live
//
//  Created by chsb on 16/8/2.
//  Copyright © 2016年 chensb. All rights reserved.
//
import lf
import UIKit
import AVFoundation
class WatchStreamViewController: UIViewController {

    var videoTime :Int64 = 0
    let liveStream = WebsocketLiveStream()
    let lfView:GLLFView! = GLLFView(frame: CGRectZero)
    var roomID : Int64?{
        didSet{
            dispatch_async(dispatch_get_main_queue()) {
                SingletonSocket.sharedInstance.joinRoom(self.roomID!)
            }
            
        }
    }
    var publishButton:UIButton = {
        let button:UIButton = UIButton()
        button.backgroundColor = UIColor.blueColor()
        button.setTitle("Live", forState: .Normal)
        button.layer.masksToBounds = true
        return button
    }()
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        lfView.frame = view.bounds
        
        lfView.backgroundColor = UIColor.redColor()
        lfView.translatesAutoresizingMaskIntoConstraints = true
        
        lfView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        lfView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        publishButton.frame = CGRect(x: view.bounds.width - 44 - 20, y: view.bounds.height - 44 - 20, width: 44, height: 44)
        log.info("width \(view.bounds.width) height \(view.bounds.height)   ")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bounds = UIScreen.mainScreen().applicationFrame
        //log.info("screen size \(UIScreen.mainScreen().applicationFrame)   view bounds \(self.view.bounds)   ")
        self.publishButton.didMoveToSuperview()
        //self.liveStream.attachCamera(DeviceUtil.deviceWithPosition(.Back))
       // self.lfView.attachStream(liveStream)
        lfView.transform = CGAffineTransformMakeRotation(CGFloat((180) * (-90)  * M_PI/180.0));
        self.liveStream.syncOrientation = true
        self.liveStream.mixer.videoIO.encoder.stopRunning()
        
        
        //self.lfView.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.lfView.attachStream(liveStream)
        publishButton.addTarget(self, action: #selector(PushViewController.onClickPublish(_:)), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.lfView)
        self.view.addSubview(self.publishButton)
        self.liveStream.mixer.videoIO.drawable = self.lfView
        self.liveStream.captureSettings = [
            "sessionPreset": AVCaptureSessionPreset1280x720,
            "continuousAutofocus": true,
            "continuousExposure": true,
        ]
        
        self.liveStream.videoSettings = [
            "width": 1280,
            "height": 720,
        ]
        self.lfView.position = .Back
        
        ProtoHandler.sharedInstance.watchViewController = self
    }
    
    func enqueueSampleBuffer(payload:[UInt8]){
        
        let array = Array(payload[2..<5])
        var value = array.withUnsafeBufferPointer({
            UnsafePointer<Int32>($0.baseAddress).memory
        })
        value = Int32(bigEndian: value)
        let compositionTimeoffset:Int32 = value
        
        self.videoTime += Int64(compositionTimeoffset)
        var timing:CMSampleTimingInfo = CMSampleTimingInfo(
            duration: CMTimeMake(Int64(1), 1000),
            presentationTimeStamp: CMTimeMake(Int64(self.videoTime) + Int64(compositionTimeoffset), 1000),
            decodeTimeStamp: kCMTimeInvalid
        )

        let bytes:[UInt8] = Array(payload[5..<payload.count])
        var sample:[UInt8] = bytes
        let sampleSize:Int = bytes.count
        var blockBuffer:CMBlockBufferRef?
        guard CMBlockBufferCreateWithMemoryBlock(
            kCFAllocatorDefault, &sample, sampleSize, kCFAllocatorNull, nil, 0, sampleSize, 0, &blockBuffer) == noErr else {
                return
        }
        var sampleBuffer:CMSampleBufferRef?
        var sampleSizes:[Int] = [sampleSize]
        guard CMSampleBufferCreate(kCFAllocatorDefault, blockBuffer!, true, nil, nil, self.liveStream.mixer.videoIO.formatDescription, 1, 1, &timing, 1, &sampleSizes, &sampleBuffer) == noErr else {
            return
        }
        self.liveStream.mixer.videoIO.decoder.decodeSampleBuffer(sampleBuffer!)
    }
    func createFormatDescription(payload:[UInt8]) -> OSStatus {
        var config:AVCConfigurationRecord = AVCConfigurationRecord()
        log.info("payload \(payload)")
        config.bytes = Array(payload[FLVTag.TagType.Video.headerSize..<payload.count])
        return config.createFormatDescription(&liveStream.mixer.videoIO.formatDescription)
    }
    
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickPublish(sender:UIButton) {
        if (sender.selected) {
            UIApplication.sharedApplication().idleTimerDisabled = false
            sender.setTitle("wathching", forState: .Normal)
        } else {
            self.liveStream.stop()
            sender.setTitle("wathch", forState: .Normal)
        }
        sender.selected = !sender.selected
    }
    

}
