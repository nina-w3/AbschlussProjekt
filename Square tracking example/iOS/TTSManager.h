//
//  TTSManager.h
//  artoolkitX Square Tracking Example
//
//  Created by user on 30.08.21.
//  Copyright © 2021 artoolkit.org. All rights reserved.
//gut#import <UIKit/UIKit.h>
#ifndef TTSManager_h
#define TTSManager_h

#import <Foundation/Foundation.h>

void tts(void);
int drawLoadModel(const char *path);
void drawSetModel(int modelIndex, bool visible, float pose[16]); // Notwendig warum?
void sound(int markerCount);
//void voice(int markerUID);
void voice(int markerId, int markerCount, NSString *title);
void ton();
//@class GreeterSwift; 



#endif /* TTSManager_h */
