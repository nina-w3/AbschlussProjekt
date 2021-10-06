//
//  ARViewController.mm

/*
 TODO aus dem Antrag (+ = erledigt)
 +Screensaver ausschalten
 +Gesture TabTAb
 -    muss noch korrekt verbunden werden, Technik steht
 +Voiceover
 +TTS
 +Sound
 -Datenbank
 schwammig:
 -Leitsystem - Meter?
 
 optional
 -stop()? bei Voiceover bereits implementiert einmal mit 2 finger tippen.
 
 Anwendungsfälle:
 -schneller weiter zu 2. Marker "stoppen"
 -Marker ignorieren
 -Abbrechen der Ansage: mit Geste Stoppen
 >1 Marker in Sichtbereich: Ansage "n. Marker in Sicht"
 
 
 vielleicht interessant:
 Sleep, delay, timer
 */


#import "ARViewController.h"
//#import <OpenGLES/ES2/glext.h>
#ifdef DEBUG
#  import <unistd.h>
#  import <sys/param.h>
#endif

#import <string>
#import <ARX/ARController.h>
#import "TTSManager.h"
#import "SoundManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "artoolkitX Square Tracking Example-Bridging-Header.h"
#import "AppDelegate.h"


struct marker {
    const char *name;
    float height;
};
static const struct marker markers[] = {
    {"hiro.patt", 80.0},
    {"kanji.patt", 80.0}
};
//static const int markerCount = (sizeof(markers)/sizeof(markers[0]));
static const int markerCount = 2;

//Definition des Interface
@interface ARViewController () {
    //hier wird das aussehen des ARVIEWController angelegt.

    ARController *arController;
    long frameNo;
    int contextWidth;
    int contextHeight;
    bool contextRotate90;
    bool contextFlipH;
    bool contextFlipV;
    bool contextWasUpdated;
    int32_t viewport[4];
    float projection[16];
    int markerUID[markerCount];
    int markerModelIDs[markerCount];
   
}
//Alle Properties sowie Methodenparameter und -rückgabewerte, die in Objective-C deklariert sind, werden standardmäßig in Swift als Implicity Unwrapped Optionals importiert. D.h., wenn die Parameter nicht explizit mit nonnull gekennzeichnet sind, werden sie von Swift als optional und nicht als Pfichtwert verstanden.
//Property fuer den Context
//TODO: Eventuell auskommentieren, Grafischer Content. (GL)
//EaGLContext *context //Deklaration einer Pointervariablen, Pointer zu einem EAGLContext
@property (strong, nonatomic) EAGLContext *context;
// Methoden oder Parameter
- (void)setupGL;
- (void)tearDownGL;
@end

//Implementierung des Inferface
@implementation ARViewController

//viewdidLoad methode is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
- (void)viewDidLoad
{

    //super methode wird aufgerufen, und dann Ergänzungen angehängt
    [super viewDidLoad];
    
    //Screensaver ausschalten - wird nicht mehr dunkel
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//    tapGesture.numberOfTapsRequired = 2;
//    [self.view addGestureRecognizer:tapGesture];
////    [tapGesture release];
   
    //Gesture
    UITapGestureRecognizer *tapGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
#ifdef DEBUG
    arLogLevel = AR_LOG_LEVEL_DEBUG;
#endif
    
    // Init instance variables.
    arController = nil;
    frameNo = 0L;
    contextWidth = 0;
    contextHeight = 0;
    contextRotate90 = true; contextFlipH = contextFlipV = false;
    contextWasUpdated = false;
    //hier werden alle MarkerIDS bzw MArkerModelIDs auf -1 gesetzt.
    for (int i = 0; i < markerCount; i++)
        markerUID[i] = -1;
    for (int i = 0; i < markerCount; i++) markerModelIDs[i] = -1;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
}
//Kameraausrichtung,
- (void)viewDidLayoutSubviews
{
    GLKView *view = (GLKView *)self.view;
    //Erstellung von einem Pointer view vom Typ GLKView. mit gecasteter Zuweisung der View von UIViewController
    [view bindDrawable];
    // bindDrawable von GLKView.h, Binds the context and drawable. This needs to be called when the currently bound framebuffer has been changed during the draw method.
    
    contextWidth = (int)view.drawableWidth;
    contextHeight = (int)view.drawableHeight;
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationLandscapeLeft:
            contextRotate90 = false; contextFlipH = contextFlipV = true;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            contextRotate90 = contextFlipH = contextFlipV = true;
            break;
        case UIInterfaceOrientationLandscapeRight:
            contextRotate90 = contextFlipH = contextFlipV = false;
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationUnknown:
        default:
            contextRotate90 = true; contextFlipH = contextFlipV = false;
            break;
    }
    contextWasUpdated = true;

}
//Alles zurücksetzen
- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}
//wenn Memorywarnung, alles zurück!
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL //ARController wird initialisiert+ Marker hinzugefügt,SOwie Art/Größe der Marker angegeben
{
    char vconf[] = "-preset=720p";
    
    [EAGLContext setCurrentContext:self.context];
    
    // Initialise the ARController.
    arController = new ARController();
    if (!arController->initialiseBase()) {
        ARLOGe("Error initialising ARController.\n");
        return;
    }
    
    // Add markers.
#ifdef DEBUG
    char buf[MAXPATHLEN];
    ARLOGe("CWD is '%s'.\n", getcwd(buf, sizeof(buf)));
#endif
    int markerAnzeigeWert = 0; //theoretisch Datenbank abfrage, lade die Marker aus dem Bereich "Stuttgart" aus der DAtenbank
    char *resourcesDir = arUtilGetResourcesDirectoryPath(AR_UTIL_RESOURCES_DIRECTORY_BEHAVIOR_BEST);
    for (int i = 0; i < markerCount; i++) {
        /*
         Marker werden in einer Schleife hinzuaddiert, das i wird zur UID des Markers, ist  unabhängig von dem Namen des Markers, also die UID 0 kann trotzdem zum Marker 85345 gehören. Vorteil könnte daher sein, ich lade mir die Marker von der Datenbank, beschränke auf X Marker laden, und die haben dann immer den Zahlenbereich von 0 bzw 1 bis x.
         */
       // std::string markerConfig = "single;" + std::string(resourcesDir) + '/' + markers[i].name + ';' + std::to_string(markers[i].height);
        
        std::string markerConfig = "single_barcode;"+ std::to_string(markerAnzeigeWert) + ";80"; //size aus der Datenbankbzw alles aus der DAtenbank nehmen.
        markerAnzeigeWert +=855555; //spasseshalber mal bissl mehr, damit auch der Name von der UID abweicht

        markerUID[i] = arController->addTrackable(markerConfig);
        NSLog(@"Der wert von MarkerIDs = %x\n", markerUID[i]);
        if (markerUID[i] == -1) {
            ARLOGe("Error adding marker.\n");
            return;
        }
    }
    //Marker Size
    arController->getSquareTracker()->setPatternDetectionMode(AR_MATRIX_CODE_DETECTION);
    arController->getSquareTracker()->setThresholdMode(AR_LABELING_THRESH_MODE_AUTO_BRACKETING);
    arController->getSquareTracker()->setMatrixCodeType(AR_MATRIX_CODE_6x6); //ANGEPASST!!!

    // Start tracking.
    arController->startRunning(vconf, NULL, NULL, 0);
}
//zurücksetzen
- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    //drawCleanup();
    if (arController) {
        arController->drawVideoFinal(0);
        arController->shutdown();
        delete arController;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    bool gotFrame = arController->capture();
    if (gotFrame) {
        //ARLOGi("Got frame %ld.\n", frameNo);
        frameNo++;
        
        if (!arController->update()) {
            ARLOGe("Error in ARController::update().\n");
            return;
        }
    }
}
ARTrackable *currentMarker = nil;


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if (arController->isRunning()) {
       
       if (contextWasUpdated) {
            //WEnn man die naechsten beiden Zeilen auskommentiert, kommt kein KameraBild mehr
            arController->drawVideoInit(0);
            arController->drawVideoSettings(0, contextWidth, contextHeight, contextRotate90, contextFlipH, contextFlipV, ARVideoView::HorizontalAlignment::H_ALIGN_CENTRE, ARVideoView::VerticalAlignment::V_ALIGN_CENTRE, ARVideoView::ScalingMode::SCALE_MODE_FIT, viewport);
            // Ende Kamerabild

            for (int i = 0; i < markerCount; i++) {
                markerModelIDs[i] = drawLoadModel(NULL);
            }
            contextWasUpdated = false;
        }
        
        // Clean the OpenGL context.
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        // Display the current video frame to the current OpenGL context.
        arController->drawVideo(0);

        // Look for markers, and draw on each found one.
        for (int i = 0; i < markerCount; i++) {
            BOOL isVoiceOverRunning = (UIAccessibilityIsVoiceOverRunning() ? 1 : 0);
            // Find the marker for the given marker ID.
            ARTrackable *marker = arController->findTrackable(markerUID[i]);
          
            float view[16];
            if (marker->visible) { //Original
           // if (marker->visiblePrev) { //Whether or not the trackable was visible prior to last Update
                //arUtilPrintMtx16(marker->transformationMatrix); //bereits auskommentiert gewesen
                    sound(markerModelIDs[i]); //MarkerUID mitgeben
                    voice(markerModelIDs[i]);
                    //ton();
            }
            drawSetModel(markerModelIDs[i], marker->visible, view);
        }
        //draw();
    }
}

//The event handling method
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        // handling code
        NSLog(@"TAP TAP");
      //  voice(markerModelIDs[1]);
       //Voiceover verdeckt diese GEste
        AVSpeechUtterance *utterance;
        utterance = [AVSpeechUtterance speechUtteranceWithString:@"Hallo"];
        
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
        [utterance setRate:0.5f];
        //[utterance setPostUtteranceDelay:1000000];
        [synthesizer speakUtterance:utterance]; //Ausgabe
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"de-DE"];
        
    }
}
@end



