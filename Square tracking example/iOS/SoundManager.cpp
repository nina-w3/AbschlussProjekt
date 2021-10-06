//
//  SoundManager.cpp
//  artoolkitX Square Tracking Example
//
//  Created by user on 27.08.21.
//  Copyright © 2021 artoolkit.org. All rights reserved.
//

//#include "AVFoundation/AVFoundation.h"
//#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
//
//
//#if HAVE_GLES2 || HAVE_GL3
//#  include <ARX/ARG/mtx.h>
//#  include <ARX/ARG/shader_gl.h>
//
//#endif // HAVE_GLES2 || HAVE_GL3
//
//#define Models_MAX 32
//
//#include <AudioToolbox/AudioServices.h>
//#import <QuartzCore/QuartzCore.h>
//
//
//#if HAVE_GLES2 || HAVE_GL3
//// Indices of GL program uniforms.
//enum {
//    UNIFORM_MODELVIEW_PROJECTION_MATRIX,
//    UNIFORM_COUNT
//};
//// Indices of of GL program attributes.
//enum {
//    ATTRIBUTE_VERTEX,
//    ATTRIBUTE_COLOUR,
//    ATTRIBUTE_COUNT
//};
////static GLint uniforms[UNIFORM_COUNT] = {0};
////static GLuint program = 0;
//
//#if HAVE_GL3
//
//#endif // HAVE_GL3
//
//#endif // HAVE_GLES2 || HAVE_GL3
//
////static ARG_API drawAPI = ARG_API_None;
//
//static bool gModelLoaded[Models_MAX] = {false};
//static float gModelPoses[Models_MAX][16];
//static bool gModelVisbilities[Models_MAX];
//
//NSString *str = @"Voice Over ist aus, Marker sichtbar ";
//
////static void drawCube(float viewProjection[16], float pose[16]);
//
//int drawLoadModel(const char *path)
//{
//    // Ignore path, we'll always draw a cube. -- Notwendig, aber wieso?
//    for (int i = 0; i < Models_MAX; i++) {
//        if (!gModelLoaded[i]) {
//            gModelLoaded[i] = true;
//            return i;
//        }
//    }
//    return -1;
//}
//
//void drawSetModel(int modelIndex, bool visible, float pose[16])
//{
//    
//    if (modelIndex < 0 || modelIndex >= Models_MAX) return;
//    if (!gModelLoaded[modelIndex]) return;
//    
//    gModelVisbilities[modelIndex] = visible;
//    if (visible)
//        mtxLoadMatrixf(&(gModelPoses[modelIndex][0]), pose);
//  
//}
//
//
//void sound(int markerUID)
//{
//   for (int i = 0; i < Models_MAX; i++) {
//        if (gModelLoaded[i] && gModelVisbilities[i]) {
//          
//           // AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); //wenn Sound ausgestellt ist am Iphone
//            AudioServicesPlayAlertSound(1105); // Vibriert auch ohne die Zeile davor
//            //NSLog(@"MarkerUID= %x\n", markerUID);
//       
//        }
//    }
//}
//int currentMarkerUID = -1;
//void voice(int markerUID)
//{
//    for (int i = 0; i < Models_MAX; i++) {
//        if (gModelLoaded[i] && gModelVisbilities[i]) {
//            
//            if (markerUID != currentMarkerUID){
//                currentMarkerUID = markerUID;
//                NSLog(@"Marker %d\n CurrentMarker %d\n",markerUID , currentMarkerUID);
//                
//                
//                AVSpeechUtterance *utterance;
//                if (markerUID == 1)
//                    utterance = [AVSpeechUtterance speechUtteranceWithString:@"Hallo Hansjörg"];
//                if (markerUID == 0)
//                    utterance = [AVSpeechUtterance speechUtteranceWithString:@"Hallo Petra"];
//                AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
//                [utterance setRate:0.5f];
//                //[utterance setPostUtteranceDelay:1000000];
//                [synthesizer speakUtterance:utterance]; //Ausgabe
//                utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"de-DE"];
//               
//            }
//        }
//    }
//}

