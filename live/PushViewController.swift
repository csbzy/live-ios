//
//  PushViewController.swift
//  LivePush
//
//  Created by 成杰 on 16/5/25.
//  Copyright © 2016年 swiftc.org. All rights reserved.
//
import lf
import UIKit
import AVFoundation
import Foundation

class PushViewController: UIViewController{

    

    let liveStream = WebsocketLiveStream()
    let lfView:GLLFView! = GLLFView(frame: CGRectZero)
    var publishButton:UIButton = {
        let button:UIButton = UIButton()
        button.backgroundColor = UIColor.blueColor()
        button.setTitle("Live", forState: .Normal)
        button.layer.masksToBounds = true
        return button
    }()
    
    var videoBitrateLabel:UILabel = {
        let label:UILabel = UILabel()
        label.textColor = UIColor.whiteColor()
        return label
    }()
    var videoBitrateSlider:UISlider = {
        let slider:UISlider = UISlider()
        slider.minimumValue = 32
        slider.maximumValue = 1024
        return slider
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.publishButton.didMoveToSuperview()
        self.liveStream.attachCamera(DeviceUtil.deviceWithPosition(.Back))
        self.liveStream.attachAudio(AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio))
        self.lfView.attachStream(liveStream)
        
        self.publishButton.addTarget(self, action: #selector(PushViewController.onClickPublish(_:)), forControlEvents: .TouchUpInside)
        
        self.videoBitrateSlider.addTarget(self, action: #selector(PushViewController.onSliderValueChanged(_:)), forControlEvents: .ValueChanged)
        videoBitrateSlider.value = Float(RTMPStream.defaultVideoBitrate) / 1024
        
        
        self.liveStream.syncOrientation = true
        
        
        self.liveStream.addObserver(self, forKeyPath: "currentFPS", options: NSKeyValueObservingOptions.New, context: nil)
        //rtmpStream.attachScreen(ScreenCaptureSession())
        
        self.liveStream.captureSettings = [
          //  "sessionPreset": AVCaptureSessionPresetiFrame1280x720,
            "sessionPreset":        AVCaptureSessionPresetHigh,
            "continuousAutofocus": true,
            "continuousExposure": true,
        ]
        
        self.liveStream.videoSettings = [
            "width": 720,
            "height": 1280,
        ]

        self.view.addSubview(self.lfView)
        self.view.addSubview(videoBitrateSlider)
        self.view.addSubview(videoBitrateLabel)
        self.view.addSubview(self.publishButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        lfView.frame = view.bounds
        
         //log.info("view's bounds \(view.bounds),lfview's fram \(lfView.frame)'")
        publishButton.frame = CGRect(x: view.bounds.width - 44 - 20, y: view.bounds.height - 44 - 20, width: 44, height: 44)
        videoBitrateLabel.text = "video \(Int(videoBitrateSlider.value))/kbps"
        videoBitrateLabel.frame = CGRect(x: view.frame.width - 150 - 60, y: view.frame.height - 44 * 2 - 22, width: 150, height: 44)
        videoBitrateSlider.frame = CGRect(x: 20, y: view.frame.height - 44 * 2, width: view.frame.width - 44 - 60, height: 44)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
        func onClickPublish(sender:UIButton) {
            if (sender.selected) {
                UIApplication.sharedApplication().idleTimerDisabled = false
                self.liveStream.publish()
                sender.setTitle("living", forState: .Normal)
            } else {
                self.liveStream.stop()
                sender.setTitle("Live", forState: .Normal)
            }
            sender.selected = !sender.selected
        }
    
    
    func onSliderValueChanged(slider:UISlider) {
        if (slider == videoBitrateSlider) {
            videoBitrateLabel.text = "video \(Int(slider.value))/kbsp"
            self.liveStream.videoSettings["bitrate"] = slider.value * 1024
        }
    }

    
}
