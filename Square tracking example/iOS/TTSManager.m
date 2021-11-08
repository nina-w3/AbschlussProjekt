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
#import <UIKit/UIKit.h>
#import "artoolkitX Square Tracking Example-Bridging-Header.h"
//#import "AppDelegate.h"

/// Gewuenscht ist "VoiceOver", wenn das nicht eingeschaltet ist, dann TTS
/// TODO: richtiger Text ansagen! index: 0 = markerID, 1= size, 2= title, 3=text
/// ich muss also die info 2/3 unter abgleich MArkerID abholen.

#include "AVFoundation/AVFoundation.h"
#import <AudioToolbox/Audiotoolbox.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#if HAVE_GLES2 || HAVE_GL3
#  include <ARX/ARG/mtx.h>
#  include <ARX/ARG/shader_gl.h>

#endif // HAVE_GLES2 || HAVE_GL3

#define Models_MAX 32

#include <AudioToolbox/AudioServices.h>
#import <QuartzCore/QuartzCore.h>


#if HAVE_GLES2 || HAVE_GL3
// Indices of GL program uniforms.
enum {
    UNIFORM_MODELVIEW_PROJECTION_MATRIX,
    UNIFORM_COUNT
};
// Indices of of GL program attributes.
enum {
    ATTRIBUTE_VERTEX,
    ATTRIBUTE_COLOUR,
    ATTRIBUTE_COUNT
};
//static GLint uniforms[UNIFORM_COUNT] = {0};
//static GLuint program = 0;

#if HAVE_GL3

#endif // HAVE_GL3

#endif // HAVE_GLES2 || HAVE_GL3

//static ARG_API drawAPI = ARG_API_None;

static bool gModelLoaded[Models_MAX] = {false};
static float gModelPoses[Models_MAX][16];
static bool gModelVisbilities[Models_MAX];

int currentMarkerId = -1; //definitiv nicht im MarkerAnzeigeWErt-Bereich. Initialisieren der App damit nicht beim Starten die DAten vom ketzten erkannten Marker angesagt werden. Errormeldung falls Marker nicht geladen wurden
BOOL isVoiceOverRunning = (UIAccessibilityIsVoiceOverRunning() ? 1 : 0); //Ternäre abfrage

NSString *str = @"Voice Over ist aus, Marker sichtbar ";

//static void drawCube(float viewProjection[16], float pose[16]);
// Pfad wird mit gegeben, wieso auch immer, da er ja scheinbar ignoriert werden soll.
//die Schleife geht 32 mal durch(? und warum hard 32) schaut ob das hier erstellte gModel, stellt alle gModelLoaded auf true und gibt die Anzahl der geladenen zurück
int drawLoadModel(const char *path)
{
    // Ignore path, we'll always draw a cube.
    for (int i = 0; i < Models_MAX; i++) {
        if (!gModelLoaded[i]) {
            gModelLoaded[i] = true;
            return i;
        }
    }
    return -1;
}


void drawSetModel(int modelIndex, bool visible, float pose[16])
{
    //Abbruch wenn zu klein oder zu gross
    if (modelIndex < 0 || modelIndex >= Models_MAX) return;
    if (!gModelLoaded[modelIndex]) return;
    
    //ab hier der sichtbare Marker wird auf visible gesetzt.
    gModelVisbilities[modelIndex] = visible;
    if (visible)
        mtxLoadMatrixf(&(gModelPoses[modelIndex][0]), pose);
  
}


void sound()
{
   for (int i = 0; i < 10; i++) {
        if (gModelLoaded[i] && gModelVisbilities[i]) {
           // AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); //wenn Sound ausgestellt ist am Iphone
            AudioServicesPlayAlertSound(1105);// Vibriert auch ohne die Zeile davor
        }
    }
}

void voice(int markerId, int markerCount, NSString *title)
{
    for (int i = 0; i < 10; i++) {
        if (gModelLoaded[i] && gModelVisbilities[i]) {
            
            if (markerId != currentMarkerId){
                currentMarkerId = markerId;
                
               // std::string sprich = "Dieser Marker hat die UID "+ std::to_string(markerUID);
                NSString *theAnswer = [NSString stringWithFormat:@"%@", title];
                
                NSLog(@"Marker %d\n CurrentMarker %d\n",markerId , currentMarkerId);
                if (isVoiceOverRunning == 0){
                    AVSpeechUtterance *utterance;
                    utterance = [AVSpeechUtterance speechUtteranceWithString:theAnswer];
                    NSLog(@"%@", theAnswer);
                    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
                    [utterance setRate:0.5f];
                    //[utterance setPostUtteranceDelay:1000000];
                    [synthesizer speakUtterance:utterance]; //Ausgabe
                    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"de-DE"];
                    }
                if (isVoiceOverRunning == 1){
                    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                                    theAnswer);
                }
            }
        }
    }
    
}


//Funktioniert noch nicht: Ton Pitch!
/** Das nächste Sample erzeugen */
Float32 getNextSample() {
    static double phase = 0;
    phase += 6.282 * 440 / 44100;   //440 Hz bei 44.1 kHz Sample Rate
    return sin(phase);
}
/** Callback, um einen Audio-Buffer zu füllen */
OSStatus MyRenderCallback(void* inRefCon,
                          AudioUnitRenderActionFlags* ioActionFlags,
                          const AudioTimeStamp* inTimeStamp,
                          UInt32 inBusNumber,
                          UInt32 inNumberFrames,
                          AudioBufferList* ioData) {
    for (int i=0; i<inNumberFrames; i++) {
        Float32 sample = getNextSample();
        for (int j=0; j<ioData->mNumberBuffers; j++) {
            Float32* base = (Float32*)ioData->mBuffers[j].mData;
            for (int k=0; k<ioData->mBuffers[j].mNumberChannels; k++) {
               base[i * ioData->mBuffers[j].mNumberChannels + k] = sample;
            }
        }
    }
    return 0;
}
//@implementation AppDelegate : NSObject
void ton() {
    for (int i = 0; i < Models_MAX; i++) {
         if (gModelLoaded[i] && gModelVisbilities[i]) {
             
    //Default Output-Komponente suchen
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_GenericOutput;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    AudioComponent comp = AudioComponentFindNext(NULL, &desc);
  //  NSAssert(comp, @"Could not find default out component");

    //Eine Instanz davon erzeugen
    AudioComponentInstance outUnit;
    OSStatus err = AudioComponentInstanceNew(comp, &outUnit);
 //   NSAssert1(!err,@"AudioComponentInstanceNew failed with error %i",err);

    //Audio-Stream-Format setzen
    AudioStreamBasicDescription asbd;
    asbd.mSampleRate = 44100.0;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagsNativeFloatPacked|kAudioFormatFlagIsNonInterleaved;
    asbd.mBytesPerPacket = sizeof(Float32);            //noninterleaved -> Beschreibung fuer EINEN Kanal
    asbd.mFramesPerPacket = 1;
    asbd.mBytesPerFrame = sizeof(Float32);             //noninterleaved -> Beschreibung fuer EINEN Kanal
    asbd.mChannelsPerFrame = 2;                        //noninterleaved -> Anzahl Bufferlisten
    asbd.mBitsPerChannel = sizeof (Float32) * 8;
    asbd.mReserved=0;

    err = AudioUnitSetProperty (outUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &asbd,
                                sizeof(asbd));
  //  NSAssert1(!err,@"AudioUnitSetProperty (asbd) failed with error %i",err);

    //Audio Unit initialisieren
    err = AudioUnitInitialize(outUnit);
 //   NSAssert1(!err,@"AudioUnitInitialize failed with error %i",err);
    //Render Callback setzen
    AURenderCallbackStruct renderCallback;
    memset(&renderCallback, 0, sizeof(AURenderCallbackStruct));
    renderCallback.inputProc = MyRenderCallback;
   // renderCallback.inputProcRefCon = self;
    err = AudioUnitSetProperty (outUnit,
                                kAudioUnitProperty_SetRenderCallback,
                                kAudioUnitScope_Input,
                                0,
                                &renderCallback,
                                sizeof(AURenderCallbackStruct));
  //  NSAssert1(!err,@"AudioUnitSetProperty (callback) failed with error %i",err);
    //Los geht's!
    AudioOutputUnitStart(outUnit);
         }
}
}
//@end
