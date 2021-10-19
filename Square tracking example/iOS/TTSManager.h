//
//  TTSManager.h
//  artoolkitX Square Tracking Example
//
//  Created by user on 30.08.21.
//  Copyright © 2021 artoolkit.org. All rights reserved.
//gut#import <UIKit/UIKit.h>
#ifndef TTSManager_h
#define TTSManager_h


void tts(void);
int drawLoadModel(const char *path);
void drawSetModel(int modelIndex, bool visible, float pose[16]); // Notwendig warum?
void sound();
void voice(int markerUID);
void ton();
//@class GreeterSwift; 



#endif /* TTSManager_h */
