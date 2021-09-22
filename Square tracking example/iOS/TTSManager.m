//
//  TTSManager.m
//  artoolkitX Square Tracking Example
//
//  Created by user on 30.08.21.
//  Copyright © 2021 artoolkit.org. All rights reserved.
//
#import <ARX/ARController.h>
#include "TTSManager.h"
#include <AVFoundation/AVFoundation.h>

/// Gewuenscht ist nicht eine programmierte Sprachausgabe sondern via "VoiceOver"!
/// Zudem wiederholt sich gerade hier mein synthesizer dauernd, bleibt dann haengen. Wenn nicht Voice Over nur mit guten Grund, dann muss hier etwas gemacht werden
/// komischerweise war bei meiner testapp alles ok, einmal nur den gesamten Text ausgegeben. nicht mehr in meiner TestApp vorhanden.





void tts()
{
    //TEXT TO SPEECH TTS
    NSString *str = @"Voice Over ist aus, Marker sichtbar ";
    
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:str];
  //  [utterance setRate:0.1f];
   // [utterance setPostUtteranceDelay:1000000];
   [synthesizer speakUtterance:utterance];
//utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"de-DE"];

}

