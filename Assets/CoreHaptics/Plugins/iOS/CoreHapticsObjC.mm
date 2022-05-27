#import "CoreHapticsObjC.h"

@interface CoreHapticsObjC()
@property (nonatomic, strong) CHHapticEngine* engine;
@property (nonatomic) BOOL isEngineStarted;
@property (nonatomic) BOOL isEngineIsStopping;
@property (nonatomic) BOOL isHapticsSupported;
@end

@implementation CoreHapticsObjC

static CoreHapticsObjC * _shared;

+ (CoreHapticsObjC*) shared {
    @synchronized (self) {
        if(_shared == nil) {
            _shared = [[self alloc] init];
        }
    }
    return _shared;
}

- (id) init {
    if (self == [super init]) {

        if (@available(iOS 13, *)) {
            if (CHHapticEngine.capabilitiesForHardware.supportsHaptics) {
                self.isHapticsSupported = YES;
                [self createEngine];
            }
        }
        else {
            self.isHapticsSupported = NO;
        }
    }
    return self;
}

- (void) dealloc {
    if (self.isHapticsSupported) {
        self.engine = NULL;
    }
}

- (void) createEngine {
    if (self.isHapticsSupported) {
        NSError* error = nil;
        _engine = [[CHHapticEngine alloc] initAndReturnError:&error];

        if (error == nil) {

            _engine.playsHapticsOnly = true;
            __weak CoreHapticsObjC *weakSelf = self;

            _engine.stoppedHandler = ^(CHHapticEngineStoppedReason reason) {
                NSLog(@"[CoreHapticsObjC] The engine stopped for reason: %ld", (long)reason);
                switch (reason) {
                    case CHHapticEngineStoppedReasonAudioSessionInterrupt:
                        NSLog(@"[CoreHapticsObjC] Audio session interrupt");
                        break;
                    case CHHapticEngineStoppedReasonApplicationSuspended:
                        NSLog(@"[CoreHapticsObjC] Application suspended");
                        break;
                    case CHHapticEngineStoppedReasonIdleTimeout:
                        NSLog(@"[CoreHapticsObjC] Idle timeout");
                        break;
                    case CHHapticEngineStoppedReasonSystemError:
                        NSLog(@"[CoreHapticsObjC] System error");
                        break;
                    case CHHapticEngineStoppedReasonNotifyWhenFinished:
                        NSLog(@"[CoreHapticsObjC] Playback finished");
                        break;

                    default:
                        NSLog(@"[CoreHapticsObjC] Unknown error");
                        break;
                }

                weakSelf.isEngineStarted = false;
            };

            _engine.resetHandler = ^{
                [weakSelf startEngine];
            };
        } else {
            NSLog(@"[CoreHapticsObjC] Engine init error --> %@", error);
        }
    }
}

- (void) startEngine {
    if (!_isEngineStarted) {
        NSError* error = nil;
        [_engine startAndReturnError:&error];

        if (error != nil) {
            NSLog(@"[CoreHapticsObjC] Engine start error --> %@", error);
        } else {
            _isEngineStarted = true;
        }
    }
}

- (void) playTransientHaptic:(float) intensity :(float)sharpness {

    if (intensity > 1 || intensity <= 0) return;
    if (sharpness > 1 || sharpness < 0) return;

    if (self.isHapticsSupported) {

        if (self.engine == NULL) {
            [self createEngine];
        }
        
        [self startEngine];

        CHHapticEventParameter* intensityParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:intensity];
        CHHapticEventParameter* sharpnessParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:sharpness];

        CHHapticEvent* event = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[intensityParam, sharpnessParam] relativeTime:0];

        NSError* error = nil;
        CHHapticPattern* pattern = [[CHHapticPattern alloc] initWithEvents:@[event] parameters:@[] error:&error];

        if (error == nil) {
            id<CHHapticPatternPlayer> player = [_engine createPlayerWithPattern:pattern error:&error];

            if (error == nil) {
                [player startAtTime:0 error:&error];
            } else {
                NSLog(@"[CoreHapticsObjC] Create transient player error --> %@", error);
            }
        } else {
            NSLog(@"[CoreHapticsObjC] Create transient pattern error --> %@", error);
        }
    }
}

@end

extern "C" {
bool CoreHapticsIsSupported() {
    return [[CoreHapticsObjC shared] isHapticsSupported];
}

void LowImpact()
{
    [[CoreHapticsObjC shared] playTransientHaptic:0.6f :1.0f];
}

void MediumImpact()
{
    [[CoreHapticsObjC shared] playTransientHaptic:0.8f :1.0f];
}

void SoftImpact()
{
    [[CoreHapticsObjC shared] playTransientHaptic:0.5f :1.0f];
}

void SuccessImpact()
{
    [[CoreHapticsObjC shared] playTransientHaptic:0.9f :1.0f];
}

void FailureImpact()
{
    [[CoreHapticsObjC shared] playTransientHaptic:1.0f :1.0f];
}
}
