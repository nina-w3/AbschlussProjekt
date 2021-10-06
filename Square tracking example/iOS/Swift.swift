//
//  Swift.swift
//  artoolkitX Square Tracking Example
//
//  Created by user on 16.09.21.
//  Copyright © 2021 artoolkit.org. All rights reserved.
//

import Foundation
import CoreAudio
import AVFoundation
import UIKit



// instance variables
let SystemSoundID = 1105

@objc  class Sound_pitch : NSObject {
    
    let engine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    let changeAudioUnitTime = AVAudioUnitTimePitch()
    
    @objc func setupAudioEngine() {
        engine.attach(self.audioPlayerNode)

        engine.attach(changeAudioUnitTime)
        engine.connect(audioPlayerNode, to: changeAudioUnitTime, format: nil)
        engine.connect(changeAudioUnitTime, to: engine.outputNode, format: nil)
        try? engine.start()
        audioPlayerNode.play()
    }
    func hitSound(value: Float) {
        changeAudioUnitTime.pitch = value


      //  audioPlayerNode.scheduleFile(AudioServicesPlaySystemSound(systemSoundID), at: nil, completionHandler: nil) // File is an AVAudioFile defined previously
    }
}
